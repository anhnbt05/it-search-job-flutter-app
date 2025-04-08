import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Recruiters, Role, Users, UserStatus } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UpdateUserDto } from 'src/modules/users/dtos';

@Injectable()
export class UsersService {
  constructor(
    private readonly uploadsService: UploadsService,
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  public handleGetUsers = async () => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Users')
        .select('*');

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các người dùng.',
        );

      return data
        .map((data: Users) => omit(data, ['Password']))
        .filter((user) => user.Role !== Role.admin && user.Status === 'active')
        .sort(
          (a, b) =>
            new Date(b.CreatedAt).getTime() - new Date(a.CreatedAt).getTime(),
        );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetUser = async (userId: string, currentUserId: string) => {
    try {
      const { data } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .single<Users | null>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      if (data.Status === 'inactive')
        throw new NotFoundException(
          `Tài khoản của người dùng có tên '${data.FullName}' đã bị khoá bởi quản trị viên của hệ thống.`,
        );

      const { data: currentUser } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', currentUserId)
        .maybeSingle<Users>();

      if (!currentUser)
        throw new NotFoundException(
          `Không tìm thấy người dùng đang thao tác hiện tại có id '${currentUserId}'`,
        );

      if (currentUser.Role === Role.candidate && currentUserId !== userId)
        throw new ForbiddenException(
          `Bạn không có quyền xem thông tin cá nhân của ứng viên khác.`,
        );

      if (currentUser.Role === Role.recruiter && data.Role === Role.candidate) {
        const { data: candidate } = await this.anonSupabaseClient
          .from('Candidates')
          .select(
            '*, WorkExperiences(*) ,Users(FullName, Email, PhoneNumber, AvatarUrl, Role) ,Applications(*, Jobs(*, Recruiters(*)))',
          )
          .eq('UserID', userId)
          .maybeSingle<any>();

        if (!candidate)
          throw new NotFoundException(
            `Không tìm thấy bất kỳ thông tin ứng cử viên nào cho người dùng có id '${userId}'.`,
          );

        const { data: recruiter } = await this.anonSupabaseClient
          .from('Recruiters')
          .select('*')
          .eq('UserID', currentUserId)
          .maybeSingle<Recruiters>();

        if (!recruiter)
          throw new NotFoundException(
            'Không tìm thấy bất kỳ thông tin nhà tuyển dụng nào của bạn. Vui lòng liên hệ với quản trị viên.',
          );

        if (
          !candidate.Applications.map((application: any) => application.Jobs)
            .map((job: any) => job.Recruiters)
            .map((recruiter: any) => recruiter.ID)
            .includes(recruiter?.ID)
        )
          throw new ForbiddenException(
            `Bạn không thể xem ứng viên có tên '${candidate.Users.FullName}' bởi vì người này không ứng tuyển cho bất kỳ công việc nào mà bạn đăng.`,
          );

        return this.handleFormattedProfileCandidateResponse(candidate);
      }

      if (
        currentUser.Role === Role.recruiter &&
        data.Role === Role.recruiter &&
        data.ID !== currentUserId
      )
        throw new ForbiddenException(
          `Bạn không có quyền xem thông tin cá nhân của nhà tuyển dụng khác.`,
        );

      if (currentUser.Role === Role.admin) return omit(data, ['Password']);

      if (currentUser.Role === Role.candidate) {
        const { data: candidate } = await this.anonSupabaseClient
          .from('Candidates')
          .select(
            '*, WorkExperiences(*) ,Users(FullName, Email, PhoneNumber, AvatarUrl, Role) ,Applications(*)',
          )
          .eq('UserID', userId)
          .maybeSingle<any>();

        if (!candidate)
          throw new NotFoundException(
            `Không tìm thấy bất kỳ thông tin ứng cử viên nào cho người dùng có id '${userId}'.`,
          );

        return {
          ...this.handleFormattedProfileCandidateResponse(candidate),
          Applications: candidate.Applications,
        };
      }

      const { data: recruiter } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*, Users(*), CompanyLocations(*, Companies(*))')
        .eq('UserID', currentUserId)
        .maybeSingle<any>();

      if (!recruiter)
        throw new NotFoundException(
          'Không tìm thấy bất kỳ thông tin nhà tuyển dụng nào của bạn. Vui lòng liên hệ với quản trị viên.',
        );

      return {
        ...omit(recruiter, [
          'UserID',
          'CompanyLocationID',
          'Users',
          'CompanyLocations',
          'DeletedAt',
        ]),
        FullName: recruiter.Users.FullName,
        Email: recruiter.Users.Email,
        AvatarUrl: recruiter.Users.AvatarUrl,
        PhoneNumber: recruiter.Users.PhoneNumber,
        IsEmailVerified: recruiter.Users.IsEmailVerified,
        Company: recruiter.CompanyLocations.Companies,
        CompanyLocations: {
          ...omit(recruiter.CompanyLocations, [
            'Companies',
            'CompanyID',
            'DeletedAt',
            'LocationID',
          ]),
        },
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleUpdateUser = async (
    userId: string,
    updateUserDto: UpdateUserDto,
    currentUserId: string,
    files?: Express.Multer.File[],
  ) => {
    try {
      if (userId !== currentUserId)
        throw new ForbiddenException(
          `Bạn chỉ có thể cập nhật thông tin của chính mình.`,
        );

      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', currentUserId)
        .limit(1)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' mà liên kết với bạn.`,
        );

      if (user.Status === 'inactive')
        throw new NotFoundException(
          `Tài khoản của người dùng có tên '${user.FullName}' đã bị khoá bởi quản trị viên của hệ thống.`,
        );

      if (
        updateUserDto?.updateCandidateDto &&
        updateUserDto?.updateRecruiterDto
      )
        throw new BadRequestException(
          'Bạn chỉ có thể cập nhật đúng với vai trò của mình.',
        );

      const avatarFile = files?.find((file) => file.fieldname === 'avatarFile');

      const resumeFile = files?.find((file) => file.fieldname === 'resumeFile');

      if (
        (files && resumeFile && user.Role === Role.recruiter) ||
        user.Role === Role.admin
      ) {
        const isAdmin = user.Role === Role.admin;

        throw new BadRequestException(
          `Bạn đang là ${isAdmin === true ? 'quản trị viên' : 'nhà tuyển dụng'} nên không thể cập nhật link CV.`,
        );
      }

      const { updateCandidateDto, updateRecruiterDto, ...res } = updateUserDto;

      if (updateCandidateDto) {
        const { error } = await this.adminSupabaseClient
          .from('Candidates')
          .update([updateCandidateDto])
          .eq('UserID', userId);

        if (error) {
          console.error(error);

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi khi cập nhật thông tin ứng viên cho bạn. Vui lòng thử lại.',
          );
        }
      }

      const { error } = await this.adminSupabaseClient
        .from('Users')
        .update([res])
        .eq('ID', currentUserId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật thông tin của bạn. Vui lòng thử lại.',
        );
      }

      if (avatarFile)
        await this.handleUpdateFileUrl(
          avatarFile,
          userId,
          'AvatarUrl',
          'Users',
          'ID',
        );

      if (resumeFile)
        await this.handleUpdateFileUrl(
          resumeFile,
          userId,
          'ResumeUrl',
          'Candidates',
          'UserID',
        );

      if (updateRecruiterDto) {
        const { error } = await this.adminSupabaseClient
          .from('Recruiters')
          .update([updateRecruiterDto])
          .eq('UserID', currentUserId);

        if (error) {
          console.error(error);

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi trong quá trình cập nhật thông tin của bạn. Vui lòng thử lại.',
          );
        }
      }

      return this.handleGetUser(userId, currentUserId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteUser = async (userId: string) => {
    try {
      const { data, error: findUserError } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!data || findUserError)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      if (data.Status === 'inactive')
        throw new BadRequestException('Tài khoản này đã bị khoá rồi.');

      if (data.Role === Role.admin)
        throw new ForbiddenException(
          'Bạn không thể tự khoá chính tài khoản của mình.',
        );

      const { error } = await this.adminSupabaseClient
        .from('Users')
        .update([
          {
            DeleteAt: new Date(),
            Status: UserStatus.inactive,
          },
        ])
        .eq('ID', userId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình xoá tài khoản người dùng. Vui lòng thử lại sau.',
        );
      }

      return this.handleGetUsers();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleFormattedProfileCandidateResponse = (candidate: any) => {
    return {
      ...omit(candidate, [
        'Applications',
        'DeletedAt',
        'Users',
        'UserID',
        'WorkExperiences',
      ]),
      FullName: candidate.Users.FullName,
      Email: candidate.Users.Email,
      PhoneNumber: candidate.Users.PhoneNumber,
      AvatarUrl: candidate.Users.AvatarUrl,
      Role: candidate.Users.Role,
      WorkExperiences: candidate.WorkExperiences.map((we: any) =>
        omit(we, ['CandidateID']),
      ),
    };
  };

  private handleUpdateFileUrl = async (
    file: Express.Multer.File,
    value: string,
    field: string,
    tableName: string,
    columnName: string,
  ) => {
    const { url } = await this.uploadsService.uploadFile(file, 'files');

    const { error: updateAvatarError } = await this.adminSupabaseClient
      .from(tableName)
      .update([
        {
          [field]: url,
        },
      ])
      .eq(columnName, value);

    if (updateAvatarError) {
      console.error(updateAvatarError);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi trong quá trình cập nhật ảnh của bạn. Vui lòng thử lại.',
      );
    }
  };
}
