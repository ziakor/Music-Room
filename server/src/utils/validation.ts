export const validatePassword = (password: string): boolean => {
  const regex = new RegExp(
    '^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$',
  );
  return regex.test(password);
};
