export interface TagEditProps {
  id?: number;
  name: string;
  slug: string;
  description: string;
  lang: string;
  color?: string;
  icon?: string;
  group?: string;
  sortOrder?: number;
  isFeatured?: boolean;
  status?: string;
  coverImage?: string;
  template?: string;
}
