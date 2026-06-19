// BannerDetail.ets
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct BannerDetail {
  let
  private params: Record<string, string | ResourceStr> = router.getParams() as Record<string, string | ResourceStr>;

  @State imageSrc: ResourceStr = this.params.imageSrc as ResourceStr;
  @State title: string = this.params.title as string;
  @State brief: string = this.params.brief as string;

  // 根据标题，获取对应的Pic
  private getPicByTitle(): ResourceStr {
    // 根据标题，映射不同的Pic
    switch(this.title) {
      case '林俊杰':
        return $r('app.media.ljj');
      case '许嵩':
        return $r('app.media.xvsong');
      case '汪峰':
        return $r('app.media.wangfeng');
        default:
          return $r('app.media.wangfeng');
    }
  }

  @State isPicPlaying: boolean = false;
  @State currentGifSrc: ResourceStr = this.getPicByTitle();

  build() {
    Scroll(){
      Column() {
        Text(this.title)
          .fontSize(24)
          .fontWeight(600)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)
          .onclick(()=>{
            let webController: WebController =new WebController 
            Web({src:www.baidu.com,controller:this.WebController})

          }
          )

        Image(this.isPicPlaying ? this.currentGifSrc : this.imageSrc)
          .objectFit(ImageFit.Cover)
          .width('100%')
          .height(180)
          .borderRadius(16)
          .padding({ left:16, right:16, top:12 })
          .onClick(() => {
            this.isPicPlaying = !this.isPicPlaying;
          })

        Column() {
          Text(this.brief)
            .lineHeight(35)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .padding({ left:10,right:10,top: 10,bottom:10 })
        }
        .width('94%')
        .height(530)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding({ left:16, right:16, top:12 })
        .margin({left:16, right:16, top:16})
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f3f5')
    }
    .width('100%')
    .height('150%')
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)


  }
}