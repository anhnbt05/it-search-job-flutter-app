import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import {
  Candidates,
  Recruiters,
  Role,
  UserDevices,
  UserNotifications,
  Users,
  UserStatus,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { RoleEnum } from 'src/libs/common/utils';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import {
  DeleteUserQueryDto,
  SearchUsersDto,
  UpdateUserDto,
} from 'src/modules/users/dtos';

@Injectable()
export class UsersService {
  constructor(
    private readonly uploadsService: UploadsService,
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly oneSignalProvider: OneSignalProvider,
  ) {}

  public handleGetUsers = async (searchUsersDto?: SearchUsersDto) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Users')
        .select('*, Recruiters(*), Candidates(*)');

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các người dùng.',
        );
      }

      if (searchUsersDto?.candidateId) {
        const { data } = await this.anonSupabaseClient
          .from('Candidates')
          .select('*')
          .eq('ID', searchUsersDto.candidateId)
          .maybeSingle<Candidates>();

        if (!data)
          throw new NotFoundException(
            `Không tìm thấy thông tin ứng viên có id '${searchUsersDto.candidateId}'`,
          );

        return this.handleGetUser(data.UserID, data.UserID);
      }

      if (searchUsersDto?.recruiterId) {
        const { data } = await this.anonSupabaseClient
          .from('Recruiters')
          .select('*')
          .eq('ID', searchUsersDto.recruiterId)
          .maybeSingle<Recruiters>();

        if (!data)
          throw new NotFoundException(
            `Không tìm thấy thông tin nhà tuyển dụng có id '${searchUsersDto.recruiterId}'`,
          );

        return this.handleGetUser(data.UserID, data.UserID);
      }

      return data
        .filter((user) => user.Role !== Role.admin)
        .map((data: any) =>
          omit(
            {
              ...data,
              ID:
                data.Role === Role.recruiter
                  ? data.Recruiters[0].ID
                  : data.Candidates[0].ID,
            },
            ['Password', 'Recruiters', 'Candidates'],
          ),
        )
        .sort(
          (a, b) =>
            new Date(b.CreatedAt as string).getTime() -
            new Date(a.CreatedAt as string).getTime(),
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
            '*, WorkExperiences(*) ,Users(FullName, Email, PhoneNumber, AvatarUrl, Role, Status, IsEmailVerified) ,Applications(*, Jobs(*, Recruiters(*)))',
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
            '*, WorkExperiences(*) ,Users(FullName, Email, PhoneNumber, AvatarUrl, Role, Status, IsEmailVerified) ,Applications(*)',
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
        Status: recruiter.Users.Status,
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

      const { PhoneNumber } = res;

      if (PhoneNumber) {
        const { data: existingPhoneNumber, error } =
          await this.anonSupabaseClient
            .from('Users')
            .select('*')
            .eq('PhoneNumber', PhoneNumber)
            .neq('ID', currentUserId)
            .maybeSingle<Users>();

        if (error) {
          console.error(error);

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi khi kiểm tra số điện thoại.',
          );
        }

        if (existingPhoneNumber)
          throw new BadRequestException(
            `Số điện thoại mới này đã được sử dụng bởi người dùng khác.`,
          );
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

  public handleDeleteUser = async (
    roleId: string,
    deleteUserQueryDto: DeleteUserQueryDto,
  ) => {
    try {
      const { role } = deleteUserQueryDto;
      const { data, error: findUserError } = await this.anonSupabaseClient
        .from(`${role === RoleEnum.CANDIDATE ? 'Candidates' : 'Recruiters'}`)
        .select('*, Users(*)')
        .eq('ID', roleId)
        .maybeSingle<any>();

      if (!data || findUserError)
        throw new NotFoundException(
          `Không tìm thấy người dùng mà bạn yêu cầu cần xoá.`,
        );

      if (data.Users.Status === UserStatus.inactive)
        throw new BadRequestException('Tài khoản này đã bị khoá rồi.');

      if (data.Users.Role === Role.admin)
        throw new ForbiddenException(
          'Bạn không thể tự khoá chính tài khoản của mình.',
        );

      const { error } = await this.adminSupabaseClient
        .from('Users')
        .update([
          {
            DeletedAt: new Date(),
            Status: UserStatus.inactive,
          },
        ])
        .eq('ID', data.Users.ID);

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
      Status: candidate.Users.Status,
      IsEmailVerified: candidate.Users.IsEmailVerified,
    };
  };

  public handleGetNotificationsOfUser = async (
    userId: string,
    currentUserId: string,
  ) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*, UserNotifications(*, Notifications(*))')
        .eq('ID', userId)
        .maybeSingle<any>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      if (userId !== currentUserId)
        throw new ForbiddenException(
          'Bạn chỉ có thể xem thông báo của chính mình.',
        );

      return (
        user?.UserNotifications.map((un: any) => ({
          ...omit(un, [
            'UserID',
            'DeletedAt',
            'NotificationID',
            'Notifications',
          ]),
          Notification: {
            Title: un.Notifications.Title,
            Type: un.Notifications.Type,
          },
        })).sort(
          (a: any, b: any) =>
            new Date(b.CreatedAt as string).getTime() -
            new Date(a.CreatedAt as string).getTime(),
        ) ?? []
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetNotificationDetails = async (
    userId: string,
    notificationId: string,
    currentUserId: string,
  ) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      const { data: userNotification } = await this.anonSupabaseClient
        .from('UserNotifications')
        .select('*')
        .eq('ID', notificationId)
        .maybeSingle<any>();

      if (!userNotification)
        throw new NotFoundException(
          `Không tìm thấy thông báo có id '${notificationId}' trong hệ thống.`,
        );

      if (user.ID !== currentUserId)
        throw new ForbiddenException(
          'Bạn chỉ có thể xem thông báo chi tiết của chính mình.',
        );

      const { error } = await this.adminSupabaseClient
        .from('UserNotifications')
        .update([
          {
            IsRead: true,
          },
        ])
        .eq('ID', notificationId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật trạng thái đã đọc thông báo.',
        );
      }

      const { data: notification, error: notificationError } =
        await this.anonSupabaseClient
          .from('UserNotifications')
          .select('*, Notifications(*)')
          .eq('ID', notificationId)
          .maybeSingle<any>();

      if (notificationError) {
        console.error(notificationError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy thông báo chi tiết của bạn.',
        );
      }

      if (!notification)
        throw new NotFoundException('Không tìm thấy thông báo này.');

      return {
        ...omit(notification, ['Notifications']),
        Notification: {
          Title: notification.Notifications.Title,
          Type: notification.Notifications.Type,
        },
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteNotification = async (
    userId: string,
    notificationId: string,
    currentUserId: string,
  ) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      const { data: userNotification } = await this.anonSupabaseClient
        .from('UserNotifications')
        .select('*')
        .eq('ID', notificationId)
        .maybeSingle<UserNotifications>();

      if (!userNotification)
        throw new NotFoundException(
          `Không tìm thấy thông báo có id '${notificationId}' trong hệ thống.`,
        );

      if (user.ID !== currentUserId)
        throw new ForbiddenException(
          'Bạn chỉ có thể xoá thông báo chi tiết của chính mình.',
        );

      const { error } = await this.adminSupabaseClient
        .from('UserNotifications')
        .delete()
        .eq('ID', notificationId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi xoá thông báo chi tiết. Vui lòng thử lại sau.',
        );
      }

      return this.handleGetNotificationsOfUser(userId, currentUserId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCalculateUserSummary = async (
    StartDate?: Date,
    EndDate?: Date,
  ) => {
    try {
      let query = this.anonSupabaseClient
        .from('Users')
        .select('Role, Status, CreatedAt');

      if (StartDate) {
        query = query.gte('CreatedAt', StartDate.toISOString());
      }

      if (EndDate) {
        query = query.lte('CreatedAt', EndDate.toISOString());
      }

      const { data, error } = await query;

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Lỗi khi lấy thống kê thông tin người dùng.',
        );
      }

      const candidates = data.filter((u) => u.Role === Role.candidate).length;

      const recruiters = data.filter((u) => u.Role === Role.recruiter).length;

      const activeUsers = data.filter(
        (u) => u.Status === UserStatus.active && u.Role !== RoleEnum.ADMIN,
      ).length;

      const blockedUsers = data.filter(
        (u) => u.Status === UserStatus.inactive && u.Role !== RoleEnum.ADMIN,
      ).length;

      return {
        total: candidates + recruiters,
        candidates,
        recruiters,
        activeUsers,
        blockedUsers,
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
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

  public unlockAccount = async (
    currentUserId: string,
    id: string,
    role: RoleEnum,
  ) => {
    const { data: admin, error } = await this.anonSupabaseClient
      .from('Users')
      .select('*')
      .eq('ID', currentUserId)
      .maybeSingle<Users>();

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy thông tin hiện tại của bạn.',
      );
    }

    if (!admin)
      throw new NotFoundException(
        'Không tìm thấy thông tin của bạn trong hệ thống.',
      );

    if (role === RoleEnum.ADMIN)
      throw new ForbiddenException(
        'Bạn không thể mở khoá tài khoản của quản trị viên.',
      );

    const { data: user, error: userError } = await this.anonSupabaseClient
      .from(`${role === RoleEnum.CANDIDATE ? 'Candidates' : 'Recruiters'}`)
      .select('*, Users(*)')
      .eq('ID', id)
      .maybeSingle<any>();

    if (userError) {
      console.error(userError);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy thông tin người dùng cần mở khoá.',
      );
    }

    if (!user)
      throw new NotFoundException(
        'Không tìm thấy tài khoản người dùng cần mở khoá.',
      );

    if (user.UserID === admin.ID)
      throw new BadRequestException(
        'Bạn không thể tự mở khoá tài khoản của chính mình.',
      );

    if (user.Users.Status === UserStatus.active)
      throw new BadRequestException(
        'Tài khoản của người này hiện không bị khoá.',
      );

    const { error: errorUpdate } = await this.adminSupabaseClient
      .from('Users')
      .update({
        Status: UserStatus.active,
        DeletedAt: null,
      })
      .eq('ID', user.UserID);

    if (errorUpdate) {
      console.error(errorUpdate);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi cập nhật thông tin tài khoản của người dùng cần mở khoá tài khoản.',
      );
    }

    return {
      success: true,
      message: `Tài khoản của người dùng '${user.Users.FullName}' đã được mở khoá.`,
    };
  };

  public handleCleanupInvalidPlayerIds = async () => {
    const { data: storedDevices, error: storedDevicesError } =
      await this.anonSupabaseClient
        .from('UserDevices')
        .select('*')
        .overrideTypes<UserDevices[], { merge: false }>();

    if (storedDevicesError) {
      console.error(storedDevicesError);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy danh sách thiết bị người dùng.',
      );
    }

    const storedPlayerIds = storedDevices.map((st) => st.PlayerID);

    const invalidPlayerIds =
      await this.oneSignalProvider.getInvalidPlayerIds(storedPlayerIds);

    if (invalidPlayerIds?.length) {
      await this.adminSupabaseClient
        .from('UserDevices')
        .delete()
        .in('PlayerID', invalidPlayerIds);
    }
  };
}
