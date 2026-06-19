import { media } from '@kit.MediaKit';
import { listItemType, musicType, resListType, resMusicType } from '../model/type';
import { get } from '../utils/req';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { musicService } from '../model/MusicService';


// 数据类型
class BannerClass {
  id: string = '';
  imageSrc: ResourceStr = '';
  title: string = '';
  brief: string = '';
  constructor(id: string, imageSrc: ResourceStr, title: string, brief: string) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.title = title;
    this.brief = brief;
  }
}

class CourseItem {
  id: string;
  title: string;
  brief: string;
  img: ResourceStr;
  constructor(id: string, title: string, brief: string, img: ResourceStr) {
    this.id = id;
    this.title = title;
    this.brief = brief;
    this.img = img;
  }
}

class TutorialItem {
  id: string;
  title: string;
  brief: string;
  img: ResourceStr;
  text:string
  constructor(id: string, title: string, brief: string, img: ResourceStr,text:string) {
    this.id = id;
    this.title = title;
    this.brief = brief;
    this.img = img;
    this.text = text;
  }
}

@Entry
@Component
struct Index {
  @State message: string = '';
  @State timer: number = 0;
  @State angle: number = 0;
  @State page: boolean = false;
  @State hotMusicList: listItemType[] = [];
  @State musicList: listItemType[] = [];
  @State refreshFlag: boolean = false;

  // ✅ 最近播放列表（全局）
  @State recentPlayList: listItemType[] = [];
  // ✅ 收藏列表本地副本（响应式）
  @State loveMusicList: listItemType[] = [];


  // 轮播图
  @State bannerList: BannerClass[] = [
    new BannerClass('1', $r('app.media.ljj'), '林俊杰', 'JJ林俊杰的创作来自最深的情感，他的声音唱出灵魂的璀璨，他把音乐和梦想当做能量，一路走到无人取代的地位，他写下华语乐坛最动人的经典乐章，撼动亚洲数十亿颗心跳。他是亚洲乐坛全能唱作天王 JJ 林俊杰。 2003年首发第一张个人创作专辑《乐行者》，取得不俗成绩；其杰出的创作才能又在之后2004年的凭借歌曲【江南】而成名，并于同年获得第15届金曲奖之「最佳演唱新人奖」。随后的【小酒窝】、【曹操】、【她说】等歌曲亦造成广大回响。2011年8月8日携手华纳，迈出世界。 2020至2021年【幸存者·如你】双维度EP，创造全新音乐视角。由JJ 林俊杰亲自领导整张专辑的企划创意与视觉，新专辑一推出便占据大中华区各大排行榜，销售量更在一个月内突破百万。 把音乐和梦想当做能量，一路走到无人取代的地位，写下华语乐坛最动人的经典乐章，他是亚洲全能唱作天王JJ林俊杰。'),
    new BannerClass('2', $r('app.media.xvsong'), '许嵩', '许嵩（Vae），1986年5月14日出生于安徽省合肥市，中国内地流行乐男歌手、原创音乐人，现任海蝶音乐公司（现为太合音乐集团）音乐总监，毕业于安徽医科大学。2006年起许嵩开始发表音乐作品，至2022年已成功发行八张个人原创专辑以及六十余首原创单曲，所有歌曲由许嵩创作词曲及音乐制作。截至2020年，许嵩已获得中歌榜、中国华鼎奖、东方风云榜、音乐风云榜等权威音乐榜单颁发的“最佳创作歌手奖”、“最佳唱作人奖”等个人奖项共20次；截至2022年，应邀为游戏、影视剧等创作主题曲包括《诗画中国》（诗画中国节目主题曲）、《雨幕》（新天龙八部端游主题曲）、《千古》（电视剧《花千骨》片头曲）等歌曲共23首；八登央视舞台，十二次登上卫视晚会献唱。'),
    new BannerClass('3', $r('app.media.wangfeng'), '汪峰', '汪峰，1971年6月29日出生于北京，祖籍江苏常州，中国内地男歌手、音乐创作人，摇滚乐队“鲍家街43号”的发起人。 ' +
      '大学期间在专业音乐学习和训练之余就开始进行摇滚乐创作并组建乐队。完成本科学业后，进入中央芭蕾舞团任副首席小提琴师，后辞职转型为职业歌手。 1994年组建“鲍家街43号”乐队并担任主唱。97年、98年随乐队发行《鲍家街43号》《风暴来临》两张专辑。2000年开始个人发展，并发表第一张个人专辑《花火》。此后发行《勇敢的心》《信仰在空中飘扬》《2020》等个人专辑，创作并演唱了《怒放的生命》《飞得更高》《春天里》《北京北京》《我爱你中国》等百余首歌曲。 2012年4月，小说《晚安北京》问世。2013年6月加盟《中国好声音第二季》担任导师并留任第三季。2014年开展“汪峰2014峰暴来临演唱会”超级巡演。2017年8月15日，汪峰首部音乐电影《存在EXISTENCE》上线，首播当日播放量便突破百万。')
  ];

  // 推荐卡片
  @State courseList: CourseItem[] = [
    new CourseItem("1", "每日推荐", "根据您的喜好为您推荐歌曲", $r('app.media.ji')),
    new CourseItem("2", "最近播放", "您最近听过的歌曲", $r('app.media.island')),
  ];

  // 提醒卡片
  @State tutorialList: TutorialItem[] = [
    new TutorialItem("1", "睡前听歌建议", "睡前适合听哪些类型的歌曲？", $r('app.media.sea'),"选歌方向\n" +
      "曲风优先：纯音乐、轻音乐、古典乐、自然白噪音（雨声、溪流、晚风），避开摇滚、说唱、快节奏流行、强鼓点曲目。\n" +
      "语速 & 旋律：选旋律平缓、节奏缓慢、音调起伏小的，推荐 60-80 拍 / 分钟的乐曲，贴合人体放松心率。\n" +
      "人声选择：想听人声就选浅吟低唱、嗓音温柔的民谣、抒情慢歌，别选歌词密集、情绪浓烈的歌曲。\n" +
      "实用小技巧\n" +
      "音量：调至隐约可闻即可，不盖过环境音，避免听觉兴奋。\n" +
      "时长：设置定时关闭（20-40 分钟），整夜播放会影响深度睡眠。\n" +
      "设备：优先外放，少戴耳机；若戴耳机选头戴式，入耳式久戴易压迫耳道、损伤听力。\n" +
      "避坑：别听追更歌、新歌、容易跟着哼唱 / 脑补剧情的曲目，容易越听越清醒。\n" +
      "歌单参考\n" +
      "纯音乐：班得瑞、久石让、钢琴独奏、古筝 / 古琴古风曲\n" +
      "白噪音：森林、雨夜、咖啡馆背景音\n" +
      "人声：温柔民谣、日系治愈慢歌、经典抒情老歌 "),
    new TutorialItem("2", "听觉疲劳建议", "长时间收听音乐会产生听觉疲劳", $r('app.media.desert'),"日常缓解\n" +
      "强制静音休息：每听音频 / 用耳机 40–60 分钟，摘下来静耳 10–15 分钟，每天累计戴耳机不超 3 小时。\n" +
      "降低音量：日常音量控制在60% 以内，嘈杂环境别刻意调高音量。\n" +
      "更换佩戴方式：少用入耳式，优先头戴式 / 外放；入耳式不要塞太深。\n" +
      "即时放松手法\n" +
      "轻揉耳周、耳垂、耳后凹陷处，每次 1–2 分钟，促进血液循环。\n" +
      "远离高分贝环境，开窗听自然声响（风声、鸟鸣），让听觉神经舒缓。\n" +
      "生活 & 习惯调整\n" +
      "睡前、独处时少戴耳机，避免耳朵持续处于工作状态。\n" +
      "减少听重低音、电音、嘶吼类强刺激音乐。\n" +
      "保证睡眠，熬夜会加重听觉敏感、酸胀疲劳。\n" +
      "预警提醒\n" +
      "若出现耳鸣、耳闷、听力发蒙、耳朵刺痛，立刻停止用耳，持续不适建议就医检查。 "),
  ];
  // 新增返回页面触发刷新
  onPageShow() {
    // 每次返回首页，触发@State变量变更，整页刷新，读取musicService最新数据
    this.refreshFlag = !this.refreshFlag;
    this.loveMusicList = [...musicService.getLoveMusicList()];
  }

  aboutToDisappear() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
  //歌曲图片旋转
  startRotation() {
    if (this.timer) {
      clearInterval(this.timer);
    }
    this.timer = setInterval(() => {
      if (musicService.isPlaying) {
        this.angle = (this.angle + 0.15) % 360;
      }
    }, 16);
  }
  // ======================
  // 播放歌曲（使用全局服务）
  // ======================
  async listClick(index: number) {
    musicService.setPlayList(this.playMusicList);
    await musicService.playSong(index);
    this.refreshFlag = !this.refreshFlag;
    this.startRotation();
  }

  // ======================
  // 生命周期：页面显示时同步 UI
  // ======================
  async aboutToAppear() {
    await musicService.init();

    musicService.registerStateChange(() => {
      this.refreshFlag = !this.refreshFlag;
      // ✅ 同步收藏列表到本地副本
      this.loveMusicList = [...musicService.getLoveMusicList()];
      if (musicService.isPlaying && this.page) {
        this.startRotation();
      }
    });

    this.getHotMusicList();
  }
////获取每日推荐歌曲方法
  async getHotMusicList() {
    const res = await get<resListType>('https://api.qqmp3.vip/api/songs.php');
    if (res.code == 200) {
      this.hotMusicList = res.data;
    }
  }
//搜索音乐方法
  async getMusicList(message: string) {
    const res = await get<resListType>('https://api.qqmp3.vip/api/songs.php?type=search&keyword=' + message);
    if (res.code == 200) {
      this.musicList = res.data;
    }
  }

  build() {
    //组件叠加
    Stack() {
      Column() {
        Row() { TittleMessage().margin({ top: 6 }); }
      //导航栏
        Tabs() {
          //子导航栏
          TabContent() {
            Scroll() {
              Column() {
                Banner({ bannerList: this.bannerList });

                Scroll() {
                  Row() {
                    ForEach(this.courseList, (item: CourseItem) => {
                      CourseCard({ item })
                        .margin({ right: 10 })
                        .onClick(() => {
                          if (item.id === "1") {
                            router.pushUrl({
                              url: "pages/DailyRecommend",
                              params: {
                                songList: this.hotMusicList
                              }
                            });
                          }
                          if (item.id === "2") {
                            router.pushUrl({
                              url: "pages/RecentMusic",
                              params: {
                                songList: musicService.getRecentPlayList()
                              }
                            });
                          }
                        });
                    });
                  }
                  .padding({ left: 10, top: 16 });
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)

                Column() {
                  ForEach(this.tutorialList, (item: TutorialItem) => {
                    TutorialCard({ item }).margin({ top: 16 });
                  });
                }
                .padding(10)
              }
            }
          }
          .tabBar('推荐')
          .backgroundColor(Color.White)


          // 搜索导航
          TabContent() {
            Column() {
              Row() {
                TextInput({ placeholder: '搜索', text: $$this.message }).layoutWeight(1);
                Button('搜索').onClick(async () => {
                  await this.getMusicList(this.message);
                });
              }.padding(15);

              List({ space: 5 }) {
                ForEach(this.musicList, (item: listItemType, index) => {
                  ListItem() {
                    Row() {
                      Row() {
                        Image(item.pic).width(50)
                          .borderRadius(4);
                        Column() {
                          Text(item.name).fontSize(18).fontWeight(FontWeight.Bold).maxLines(1);
                          Text(item.artist).margin({ top: 5 });
                        }.alignItems(HorizontalAlign.Start).margin({ left: 10 });
                      }
                      .layoutWeight(1);

                      SymbolGlyph(musicService.isLoved(item) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                        .fontSize(22)
                        .fontColor([musicService.isLoved(item) ? '#FF0000' : '#666'])
                        .onClick(() => musicService.toggleLove(item))
                        .margin({ right: 10 })
                        .key(`love_search_${item.rid}_${this.refreshFlag}`);


                    }
                    .width('95%')
                    .padding(5)
                    .height(60)
                    .justifyContent(FlexAlign.SpaceBetween);
                  }
                  .onClick(async () => {
                    this.playMusicList = this.musicList;
                    this.listClick(index);
                  });
                });
              }
              .width('100%')
              .height('100%');
            }
          }
          .tabBar('搜索')


          // 收藏
          TabContent() {
            Column() {
              //如果喜欢音乐列表的长度为0，返回text：暂无歌曲列表
              if (this.loveMusicList.length === 0) {
                Text('暂无收藏歌曲')
                  .fontSize(16)
                  .fontColor('#999')
                  .margin({ top: 100 });
              } else {
                //否则显示收藏音乐列表
                List({ space: 5 }) {
                  ForEach(this.loveMusicList, (item: listItemType, index: number) => {
                    ListItem() {
                      Row() {
                        Image(item.pic).width(50)
                          .borderRadius(4);
                        Column() {
                          Text(item.name).fontSize(18).fontWeight(FontWeight.Bold).maxLines(1);
                          Text(item.artist).margin({ top: 5 });
                        }.alignItems(HorizontalAlign.Start).margin({ left: 10 });

                        SymbolGlyph($r('sys.symbol.heart_fill'))
                          .fontSize(22)
                          .fontColor(['#FF0000'])
                          .onClick(() => {
                            musicService.toggleLove(item);
                            // ✅ 点击后立即同步本地副本
                            this.loveMusicList = [...musicService.getLoveMusicList()];
                          })
                          .margin({ right: 10 });
                      }
                      .width('95%')
                      .padding(5)
                      .height(60)
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .key(`love_item_${item.rid}_${this.refreshFlag}`)
                    .onClick(async () => {
                      this.playMusicList = this.loveMusicList;
                      this.listClick(index);
                    });
                  }, (item: listItemType) => item.rid);
                }
                .width('100%')
                .layoutWeight(1);
              }
            }
            .width('100%')
            .height('100%');
          }
          .tabBar('收藏')

        }
        .layoutWeight(1)
        .width('95%')

        // ======================
        // ✅ 底部播放条（全部使用全局服务）
        // ======================
          Progress({
            value: musicService.currentTime,
            total: musicService.duration,
            type: ProgressType.Linear
          }).width('100%')
            .key(`progress_${this.refreshFlag}`);


        Row() {
            Image(musicService.pic).width(60)
              .borderRadius(8)
              .key(`pic_${this.refreshFlag}`);
            Column({ space: 10 }) {
              Text(musicService.name).fontSize(18).fontWeight(FontWeight.Bold).maxLines(1)
                .key(`name_${this.refreshFlag}`);
              Text(musicService.singer)
                .key(`singer_${this.refreshFlag}`);
            }.layoutWeight(1).margin({ left: 15 });

          SymbolGlyph($r('sys.symbol.backward_end_fill'))
            .fontSize(35)
            .onClick(() => musicService.playPrev());

          SymbolGlyph(musicService.isPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
            .fontSize(30)
            .onClick(() => musicService.playPause())
            .key(`play_${this.refreshFlag}`);

          SymbolGlyph($r('sys.symbol.forward_end_fill'))
            .fontSize(35)
            .onClick(() => musicService.playNext());
        }
        .width('100%')
        .padding(15)
        .backgroundColor(Color.White)
        .onClick(() => { this.page = true; });

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5');

      // ======================
      // ✅ 播放详情页（全局服务数据）
      // ======================
      if (this.page) {
        Column() {
          Row() {
            Column().width(30);
            Text(musicService.name).fontSize(30);
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(30)
              .onClick(() => {
                this.page = false;
                if (this.timer) {
                  clearInterval(this.timer);
                }
              });
          }.justifyContent(FlexAlign.SpaceBetween).width('100%').padding(15);

          Text(musicService.singer).fontSize(20);

          Image(musicService.pic)
            .width(280)
            .height(280)
            .margin({ top: 80 })
            .borderRadius(150)
            .rotate({ angle: this.angle })
            .animation({
              duration: 16,
              iterations: 1
            });
          Row() {
            Text(`${Math.floor(musicService.currentTime / 60000)}:${Math.floor(musicService.currentTime % 60000 / 1000).toString().padStart(2, '0')}`);
            Progress({
              value: musicService.currentTime,
              total: musicService.duration,
              type: ProgressType.Linear
            }).layoutWeight(1).margin(10);
            Text(`${Math.floor(musicService.duration / 60000)}:${Math.floor(musicService.duration % 60000 / 1000).toString().padStart(2, '0')}`);
          }.width('80%').margin({ top: 80 });

          Row() {
            SymbolGlyph($r('sys.symbol.backward_end_fill')).fontSize(50).onClick(() => musicService.playPrev());
            SymbolGlyph(musicService.isPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
              .fontSize(50)
              .onClick(() => {
                musicService.playPause();
                if (!musicService.isPlaying && this.timer) {
                  clearInterval(this.timer);
                } else if (musicService.isPlaying) {
                  this.startRotation();
                }
              })
            .key(`page_play_${this.angle}`);
            SymbolGlyph($r('sys.symbol.forward_end_fill')).fontSize(50).onClick(() => musicService.playNext());
          }.width('60%').margin({ top: 80 }).justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height('100%')
        .backgroundImage(musicService.pic)
        .backgroundBlurStyle(BlurStyle.Thin)
        .onAppear(() => {
          if (musicService.isPlaying) {
            this.startRotation();
          }
        });
      }
    }
  }

  // 补充缺失的变量
  playMusicList: listItemType[] = [];
}

// ==============================
// 组件 100% 保留
// ==============================
@ComponentV2
struct TittleMessage {
  build() {
    Row() {
      Text('热门音乐播放器')
        .fontSize(24)
        .fontWeight(700)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('50%')
    .height(48)
    .borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.15)')
    .backdropBlur(20)
    .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
    .clip(true);
  }
}

@Component
struct Banner {
  //父组件传值给子组件
  @Prop bannerList: BannerClass[] = [];
  build() {
    Swiper() {
      ForEach(this.bannerList, (item: BannerClass) => {
        Image(item.imageSrc)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/BannerDetail',
             //传递图片参数值
              params: { imageSrc: item.imageSrc, title: item.title, brief: item.brief }
            })
          })
          .objectFit(ImageFit.Cover)
          .width('100%')
          .height(180)
          .borderRadius(16);

      });
    }
    .margin(16)
    .autoPlay(true)
    .loop(true);
  }
}

@Component
struct CourseCard {
  @Prop item: CourseItem;
  build() {
    Column() {
      Image(this.item.img)
        .width('100%')
        .height(96)
        .borderRadius({ topLeft: 16, topRight: 16 });
      Text(this.item.title).fontSize(14).padding(8);
      Text(this.item.brief).fontSize(12).fontColor('#666');
    }
    .width(200)
    .height(160)
    .backgroundColor(Color.White)
    .borderRadius(16);
  }
}

//教程卡片
@Component
struct TutorialCard {
  @Prop item: TutorialItem;
  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.item.title).fontSize(17);
        Text(this.item.brief).fontSize(13).fontColor('#666');
      }.layoutWeight(1).padding(10);
      Image(this.item.img).width(124).height(70).borderRadius(16);
    }
    .onClick(() => {
      router.pushUrl({
        url: 'pages/TutorialCardDetail',
        params: { imageSrc: this.item.img,title: this.item.title,text:this.item.text }
      })
    })
    .width('100%')
    .height(88)
    .backgroundColor(Color.White)
    .borderRadius(16);
  }
}