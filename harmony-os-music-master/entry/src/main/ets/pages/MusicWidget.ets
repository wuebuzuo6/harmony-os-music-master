import { WidgetDataSync, type WidgetSongItem } from '../utils/WidgetDataSync';

@Entry
@Component
struct MusicWidget {
  @State songItem: WidgetSongItem = {
    name: '歌名',
    artist: '歌手',
    pic: '',
    isPlaying: false,
    currentTime: 0,
    duration: 0
  };

  async aboutToAppear() {
    // ✅ 只在卡片创建时加载一次数据
    await this.loadData();
  }

  async loadData() {
    try {
      const newItem = await WidgetDataSync.getSongItem();
      this.songItem = newItem;
      console.info('MusicWidget loaded: ' + this.songItem.name);
    } catch (e) {
      console.error('Failed to load widget data: ' + e);
    }
  }

  build() {
    Column() {
      Row() {
        Image(this.songItem.pic && this.songItem.pic.length > 0 ?
              this.songItem.pic : $r('app.media.music_logo'))
          .width(60)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover);

        Column({ space: 4 }) {
          Text(this.songItem.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(this.songItem.artist)
            .fontSize(12)
            .fontColor('#CCCCCC')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .margin({ left: 12 })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 });

      Progress({
        value: this.songItem.currentTime,
        total: this.songItem.duration > 0 ? this.songItem.duration : 1,
        type: ProgressType.Linear
      })
        .width('90%')
        .height(4)
        .color('#1E90FF')
        .backgroundColor('#333333');

      Row() {
        Text(this.formatTime(this.songItem.currentTime))
          .fontSize(10)
          .fontColor('#CCCCCC');

        Blank();

        Text(this.formatTime(this.songItem.duration))
          .fontSize(10)
          .fontColor('#CCCCCC');
      }
      .width('90%')
      .padding({ top: 4, bottom: 4 });

      Row() {
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontSize(24)
          .fontColor(['#FFFFFF'])
          .onClick(() => {})
          .margin({ right: 20 });

        SymbolGlyph(this.songItem.isPlaying ?
                    $r('sys.symbol.pause') :
                    $r('sys.symbol.play_fill'))
          .fontSize(28)
          .fontColor(['#FFFFFF'])
          .onClick(() => {});

        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontSize(24)
          .fontColor(['#FFFFFF'])
          .onClick(() => {})
          .margin({ left: 20 });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 12 });
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.banner3'))
    .backgroundImageSize(ImageSize.Cover);
  }

  formatTime(timeMs: number): string {
    const minutes = Math.floor(timeMs / 60000);
    const seconds = Math.floor((timeMs % 60000) / 1000);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
