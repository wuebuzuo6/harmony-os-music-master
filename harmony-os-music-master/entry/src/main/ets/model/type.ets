// 歌曲基础类型
export interface listItemType {
  rid: string;
  name: string;
  artist: string;
  pic: string;
  url?: string;
  path?: string; // 本地音乐路径
}

export interface musicType {
  url: string;
}

export interface resListType {
  code: number;
  data: listItemType[];
}

export interface resMusicType {
  code: number;
  data: musicType;
}

export interface BannerItemType {
  id: string;
  imageSrc: ResourceStr;
  title: string;
}

export interface CourseItemType {
  id: string;
  title: string;
  brief: string;
  img: ResourceStr;
}
export interface RouterParams {
  songList: listItemType[];
}