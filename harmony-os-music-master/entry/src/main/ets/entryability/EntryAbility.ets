import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { WidgetDataSync } from '../utils/WidgetDataSync';
import { musicService } from '../model/MusicService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // ✅ 初始化桌面卡片数据同步
    WidgetDataSync.init(this.context).then(() => {
      hilog.info(0x0000, 'testTag', 'WidgetDataSync initialized');
    });
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      PersistentStorage.persistProp('loveMusicList', '')
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // ✅ 应用进入后台时，保持音乐继续播放
    hilog.info(0x0000, 'testTag', 'Ability onBackground, music isPlaying: ' + musicService.isPlaying);

    // 如果正在播放，不需要做任何操作，AVPlayer 会继续播放
    // 但需要确保没有被系统暂停
    if (musicService.isPlaying && musicService.avPlayer) {
      hilog.info(0x0000, 'testTag', 'Music is playing in background');
    }
  }
}
