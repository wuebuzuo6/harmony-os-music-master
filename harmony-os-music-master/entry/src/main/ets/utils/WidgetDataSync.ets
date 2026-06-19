import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
const WIDGET_DATA_STORE = 'widget_data_store';

// ✅ 定义类似 listItemType 的卡片数据结构
export interface WidgetSongItem {
  name: string;
  artist: string;
  pic: string;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
}

export class WidgetDataSync {
  private static context: common.Context = null!;
  private static dataStore: preferences.Preferences = null!;

  // ✅ 初始化（使用 APP 分区确保跨进程共享）
  static async init(context: common.Context) {
    WidgetDataSync.context = context;
    try {
      WidgetDataSync.dataStore = await preferences.getPreferences(context, WIDGET_DATA_STORE);
      console.info('WidgetDataSync initialized successfully');
    } catch (e) {
      console.error('WidgetDataSync init failed: ' + e);
    }
  }

  // ✅ 保存数据到共享存储（使用 item 风格的结构）
  static async saveFromMusicService(
    name: string,
    singer: string,
    pic: string,
    isPlaying: boolean,
    currentTime: number,
    duration: number
  ) {
    if (!WidgetDataSync.dataStore) {
      console.error('WidgetDataSync dataStore is null, cannot save');
      return;
    }

    try {
      await WidgetDataSync.dataStore.put('name', name);
      await WidgetDataSync.dataStore.put('artist', singer);
      await WidgetDataSync.dataStore.put('pic', pic);
      await WidgetDataSync.dataStore.put('isPlaying', isPlaying);
      await WidgetDataSync.dataStore.put('currentTime', currentTime);
      await WidgetDataSync.dataStore.put('duration', duration);
      await WidgetDataSync.dataStore.flush();
      console.info(`✅ Data saved to Preferences: ${name} - ${singer}`);
    } catch (e) {
      console.error('❌ Failed to save widget data: ' + e);
    }
  }

  // ✅ 从共享存储读取数据（返回类似 item 的对象）
  static async getSongItem(): Promise<WidgetSongItem> {
    if (!WidgetDataSync.dataStore) {
      console.error('❌ WidgetDataSync dataStore is null, returning default values');
      return {
        name: '歌名',
        artist: '歌手',
        pic: '',
        isPlaying: false,
        currentTime: 0,
        duration: 0
      };
    }

    try {
      const name = await WidgetDataSync.dataStore.get('name', '歌名') as string;
      const artist = await WidgetDataSync.dataStore.get('artist', '歌手') as string;
      const pic = await WidgetDataSync.dataStore.get('pic', '') as string;
      const isPlaying = await WidgetDataSync.dataStore.get('isPlaying', false) as boolean;
      const currentTime = await WidgetDataSync.dataStore.get('currentTime', 0) as number;
      const duration = await WidgetDataSync.dataStore.get('duration', 0) as number;

      console.info(`✅ Data read from Preferences: ${name} - ${artist}, playing: ${isPlaying}`);

      return {
        name,
        artist,
        pic,
        isPlaying,
        currentTime,
        duration
      };
    } catch (e) {
      console.error('❌ Failed to read widget data: ' + e);
      return {
        name: '歌名',
        artist: '歌手',
        pic: '',
        isPlaying: false,
        currentTime: 0,
        duration: 0
      };
    }
  }
}
