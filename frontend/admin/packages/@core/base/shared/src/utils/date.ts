import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.extend(relativeTime);

const dateUtil = dayjs;

dayjs.tz.setDefault('Asia/Shanghai');
dateUtil.tz.setDefault('Asia/Shanghai');

export { dateUtil };

export function formatDate(time: number | string, format = 'YYYY-MM-DD') {
  if (time === null || time === undefined || time === '') {
    return '';
  }
  if (isDate(time)) {
    return dateUtil(time).format(format);
  }

  // int64 时间戳经 protobuf JSON 序列化后是纯数字字符串，dayjs 会按
  // YYYYMMDDHHmmss 逐位解析导致年份错乱（如 1719878400000 → 1726-05-23），
  // 这里先还原为数值时间戳再交给 dayjs。
  if (typeof time === 'string' && /^\d{10,}$/.test(time.trim())) {
    return dateUtil(Number(time.trim())).format(format);
  }

  try {
    const date = dateUtil(time);
    if (!date.isValid()) {
      // throw new Error('Invalid date');
      return '';
    }
    return date.format(format);
  } catch (error) {
    console.error(`Error formatting date: ${error}`);
    return time;
  }
}

export function formatDateTime(time: number | string) {
  if (time === null || time === undefined || time === '') {
    return '';
  }
  return formatDate(time, 'YYYY-MM-DD HH:mm:ss');
}

export function isDate(value: any): value is Date {
  return value instanceof Date;
}

export function isDayjsObject(value: any): value is dayjs.Dayjs {
  return dateUtil.isDayjs(value);
}
