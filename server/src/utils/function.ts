import { random } from '@supercharge/strings/dist';

export const generateString = (size: number): string => {
  return random(size);
};
