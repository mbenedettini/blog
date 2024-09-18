import kebabcase from "lodash.kebabcase";

export const slugifyStr = (str: string) => kebabcase(str);

export const slugifyAll = (arr: string[]) => arr.map(str => slugifyStr(str));

export function slugify(text: string) {
  return text
    .toString()
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^\w-]+/g, '')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
}
