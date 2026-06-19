import { router } from '@kit.ArkUI';
import { listItemType, RouterParams } from '../model/type';
import { musicService } from '../model/MusicService';

@Entry
@Component
struct RecentMusic {
  @State songList: listItemType[] = [];
  @State refreshFlag: boolean = false;

  async aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.songList) {
      this.songList = params.songList;
      musicService.setPlayList(params.songList);
    }

    await musicService.init();
    musicService.registerStateChange(() => {
      this.refreshFlag = !this.refreshFlag;
    });
  }

  build() {
    Stack() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.arrow_left'))
            .fontSize(24)
            .onClick(() => router.back());
          Text('最近播放')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White);

        if (this.songList.length === 0) {
          Column() {
            Text('暂无最近播放记录')
              .fontSize(16)
              .fontColor('#999')
              .margin({ top: 100 });
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center);
        } else {
          List({ space: 5 }) {
            ForEach(this.songList, (item: listItemType, index: number) => {
              ListItem() {
                Row() {
                  Image(item.pic).width(50).borderRadius(4);
                  Column() {
                    Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).maxLines(1) ;
                    Text(item.artist).fontSize(12).fontColor('#666').margin({ top: 5 }) ;
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 10 })
                  .layoutWeight(1);
                  // 收藏按钮
                  SymbolGlyph(musicService.isLoved(item) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                    .fontSize(20)
                    .fontColor([musicService.isLoved(item) ? '#FF0000' : '#666'])
                    .onClick(() => musicService.toggleLove(item))
                    .margin({ right: 10 })
                    .key(`love_${item.rid}_${this.refreshFlag}`);


                  if (musicService.currentIndex === index) {
                    SymbolGlyph($r('sys.symbol.play_fill'))
                      .fontSize(20)
                      .fontColor(['#FF0000']);
                  }
                }
                .width('100%')
                .padding(8)
                .height(70)
              }
              .onClick(() => musicService.playSong(index));
            });
          }
          .layoutWeight(1)
          .width('100%');
        }

        if (musicService.currentIndex !== -1) {
          Progress({
            value: musicService.currentTime,
            total: musicService.duration,
            type: ProgressType.Linear
          }).width('100%')
            .key(`progress_${this.refreshFlag}`);

          Row() {
            Image(musicService.pic).width(50).height(50).borderRadius(8)
              .key(`pic_${this.refreshFlag}`);
            Column() {
              Text(musicService.name).fontSize(16).fontWeight(FontWeight.Bold).maxLines(1)
                .key(`name_${this.refreshFlag}`);
              Text(musicService.singer).fontSize(12).fontColor('#666')
                .key(`singer_${this.refreshFlag}`);
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
            .layoutWeight(1);

            SymbolGlyph($r('sys.symbol.backward_end_fill'))
              .fontSize(30)
              .onClick(() => musicService.playPrev());

            SymbolGlyph(musicService.isPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
              .fontSize(30)
              .onClick(() => musicService.playPause())
              .margin({ left: 10, right: 10 })
              .key(`play_${this.refreshFlag}`);

            SymbolGlyph($r('sys.symbol.forward_end_fill'))
              .fontSize(30)
              .onClick(() => musicService.playNext());
          }
          .width('100%')
          .padding(15)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#e0e0e0' });
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5');
    }
  }
}
