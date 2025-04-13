import { registerDecorator, ValidationOptions } from 'class-validator';

export function IsRealDate(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      name: 'isRealDate',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: any) {
          const date = new Date(value as string);

          return (
            /^\d{4}-\d{2}-\d{2}$/.test(value as string) &&
            !isNaN(date.getTime()) &&
            value === date.toISOString().slice(0, 10)
          );
        },
      },
    });
  };
}
