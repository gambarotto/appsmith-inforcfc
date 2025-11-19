import moment from "moment";

export const parseDate = (
  dateStr: string,
  dateFormat: string,
  locale?: string,
): Date => {
  const date = locale
    ? moment(dateStr, dateFormat).locale(locale)
    : moment(dateStr, dateFormat);

  if (date.isValid()) return date.toDate();
  else return moment().toDate();
};
