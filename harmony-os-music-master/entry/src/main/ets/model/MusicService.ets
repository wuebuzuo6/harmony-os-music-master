import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { listItemType, musicType, resMusicType } from './type';
import { get } from '../utils/req';
import { WidgetDataSync } from '../utils/WidgetDataSync';

class MusicService {
  avPlayer: media.AVPlayer = null!;
  currentIndex: number = -1;
  playList: listItemType[] = [];
  pic: string = 'https://y.gtimg.cn/music/photo_new/T062M000003j5p3V36MIwj.jpg?max_age=0';
  name: string = '歌名';
  singer: string = '歌手';
  isPlaying: boolean = false;
  currentTime: number = 0;
  duration: number = 0;
  music: musicType = {} as musicType;

  recentPlayList: listItemType[] = [];
  loveMusicList: listItemType[] = [];
  private stateChangeCallbacks: Array<() => void> = [];

//播放列表页面的方法
  registerStateChange(callback: () => void) {
    this.stateChangeCallbacks.push(callback);
  }
//播放列表页面的方法
  unregisterStateChange(callback: () => void) {
    const index = this.stateChangeCallbacks.indexOf(callback);
    if (index !== -1) {
      this.stateChangeCallbacks.splice(index, 1);
    }
  }
  //收藏页面的方法 【
  toggleLove(item: listItemType) {
    const index = this.loveMusicList.findIndex(i => i.rid === item.rid);
    if (index !== -1) {
      this.loveMusicList.splice(index, 1);
    } else {
      this.loveMusicList.push(item);
    }
    this.notifyStateChange();
  }
//播放列表页面的方法
  isLoved(item: listItemType): boolean {
    return this.loveMusicList.some(i => i.rid === item.rid);
  }
//收藏页面的方法
  getLoveMusicList(): listItemType[] {
    return this.loveMusicList;
  }
  //播放列表页面的方法
  async init() {
    if (this.avPlayer) return;
    this.avPlayer = await media.createAVPlayer();

    this.avPlayer.on('stateChange', (state) => {
      switch (state) {
        case 'initialized':
          this.avPlayer.prepare();
          break;
        case 'prepared':
          this.avPlayer.play();
          break;
        case 'playing':
          this.isPlaying = true;
          break;
        case 'paused':
          this.isPlaying = false;
          break;
      }
      this.notifyStateChange();
    });

    this.avPlayer.on('durationUpdate', (d) => {
      this.duration = d;
      this.notifyStateChange();
    });

    this.avPlayer.on('timeUpdate', (t) => {
      this.currentTime = t;
      this.notifyStateChange();

      if (t === this.duration && this.currentIndex < this.playList.length - 1) {
        this.playNext();
      }
    });
  }
//播放列表的方法
  setPlayList(list: listItemType[]) {
    this.playList = list;
  }
  private notifyStateChange() {
    this.stateChangeCallbacks.forEach(callback => callback());
    // ✅ 异步同步数据到桌面卡片（不阻塞主流程）
    this.syncToWidget();
  }

  // ✅ 同步数据到桌面卡片（异步执行）
  private syncToWidget() {
    console.info(`Saving widget data: ${this.name} - ${this.singer}, playing: ${this.isPlaying}`);

    WidgetDataSync.saveFromMusicService(
      this.name,
      this.singer,
      this.pic,
      this.isPlaying,
      this.currentTime,
      this.duration
    ).then(() => {
      console.info('Widget data saved successfully');
    }).catch((e: Error) => {
      console.error('Sync to widget failed: ' + e.message);
    });
  }
  //添加最近播放的方法
  addToRecent(item: listItemType) {
    let exists = this.recentPlayList.some(i => i.rid === item.rid);
    if (!exists) {
      this.recentPlayList = [item, ...this.recentPlayList];
    }
  }
//获取最近播放的方法
  getRecentPlayList(): listItemType[] {
    return this.recentPlayList;
  }
//获取音乐的方法
  async getMusic(id: string) {
    const res = await get<resMusicType>(`https://api.qqmp3.vip/api/kw.php?rid=${id}&type=json&level=exhigh&lrc=true`);
    if (res.code === 200) {
      this.music = res.data;
    }
  }
//播放歌曲的方法
  async playSong(index: number) {
    await this.init();
    this.currentIndex = index;
    const item = this.playList[index];

    this.pic = item.pic;
    this.name = item.name;
    this.singer = item.artist;

    await this.getMusic(item.rid);

    this.avPlayer.reset((err: BusinessError) => {
      this.avPlayer.url = this.music.url;
    });

    this.addToRecent(item);

    this.notifyStateChange();
  }
//播放下一首的方法
  async playNext() {
    if (this.currentIndex < this.playList.length - 1) {
      this.currentIndex++;
    } else {
      this.currentIndex = 0;
    }
    await this.playSong(this.currentIndex);
  }
//播放上一首的方法
  async playPrev() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
    } else {
      this.currentIndex = this.playList.length - 1;
    }
    await this.playSong(this.currentIndex);
  }
//播放暂停的方法
  playPause() {
    if (this.avPlayer.state === 'paused') {
      this.avPlayer.play();
      this.isPlaying = true;
    } else if (this.avPlayer.state === 'playing') {
      this.avPlayer.pause();
      this.isPlaying = false;
    }
    this.notifyStateChange();
  }
}

export const musicService = new MusicService();
