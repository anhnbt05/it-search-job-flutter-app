import * as bcryptjs from 'bcryptjs';

export const hashPassword = (password: string) => {
  const salt = bcryptjs.genSaltSync();

  return bcryptjs.hashSync(password, salt);
};

export const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};
