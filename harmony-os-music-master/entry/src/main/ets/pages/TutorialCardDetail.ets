import { router } from '@kit.ArkUI';

@Entry
@Component
struct TutorialCardDetail {
  private params: Record<string, string | ResourceStr> = router.getParams() as Record<string, string | ResourceStr>;

  @State imageSrc: ResourceStr = this.params.imageSrc as ResourceStr;
  @State title: string = this.params.title as string;
  @State brief: string = this.params.brief as string;
  @State text: string = this.params.text as string;
  private getPicByTitle(): ResourceStr {
    // 根据标题，映射不同的Pic
    switch(this.title) {
      case '睡前听歌建议':
        return $r('app.media.sea');
      case '听觉疲劳建议':
        return $r('app.media.desert');
      default:
        return $r('app.media.sea');
    }
  }
  @State isPicPlaying: boolean = false;
  @State currentGifSrc: ResourceStr = this.getPicByTitle();
  build() {
  Column(){
    Text(this.title)
      .fontSize(24)
      .fontWeight(600)
      .width('100%')
      .textAlign(TextAlign.Start)
      .padding({ left: 16 })
      .fontFamily('HarmonyHeiTi-Bold')
      .lineHeight(33)
    Image(this.isPicPlaying ? this.currentGifSrc : this.imageSrc)
      .objectFit(ImageFit.Cover)
      .width('100%')
      .height(180)
      .borderRadius(16)
      .padding({ left:16, right:16, top:12 })
    Column() {
      Text(this.text)
        .lineHeight(35)
        .fontSize(20)
        .textAlign(TextAlign.Start)
        .padding({ left:10,right:10,top: 10,bottom:10 })
    }
    .width('94%')
    .height(630)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left:16, right:16, top:12 })
    .margin({left:16, right:16, top:16})
  }

  }

}