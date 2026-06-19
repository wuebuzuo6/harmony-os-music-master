import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { WidgetDataSync, type WidgetSongItem } from '../utils/WidgetDataSync';

export default class MusicFormAbility extends FormExtensionAbility {
  private formId: string = '';
  private updateTimer: number = -1;

  onAddForm(want: Want) {
    console.info('MusicFormAbility onAddForm');

    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string;
    this.formId = formId || '';

    // ✅ 初始化共享数据存储（使用通用 Context）
    WidgetDataSync.init(this.context).then(() => {
      console.info('WidgetDataSync initialized in FormAbility');
      this.updateFormData();
    });

    // ✅ 启动定时器，每秒更新一次
    this.startAutoUpdate();

    // ✅ 同步返回初始数据
    return formBindingData.createFormBindingData({
      name: '歌名',
      artist: '歌手',
      isPlaying: false,
      pic: '',
      currentTime: 0,
      duration: 0
    });
  }

  onCastToNormalForm(formId: string) {
    console.info('MusicFormAbility onCastToNormalForm, formId: ' + formId);
    this.formId = formId;
  }

  onUpdateForm(formId: string) {
    console.info('MusicFormAbility onUpdateForm, formId: ' + formId);
    this.formId = formId;
    this.updateFormData();
  }

  onChangeVisibility(newStatus: Record<string, number>) {
    console.info('MusicFormAbility onChangeVisibility');
  }

  onFormEvent(formId: string, message: string) {
    console.info('MusicFormAbility onFormEvent, message: ' + message);
    this.formId = formId;

    // ✅ 处理卡片控制消息
    if (message === 'play_pause') {
      // 发送广播或调用主应用接口
      console.info('Play/Pause triggered');
    } else if (message === 'play_prev') {
      console.info('Previous song triggered');
    } else if (message === 'play_next') {
      console.info('Next song triggered');
    }
  }

  onRemoveForm(formId: string) {
    console.info('MusicFormAbility onRemoveForm, formId: ' + formId);
    if (this.updateTimer !== -1) {
      clearInterval(this.updateTimer);
    }
  }

  private startAutoUpdate() {
    this.updateTimer = setInterval(() => {
      this.updateFormData();
    }, 1000);
  }

  private async updateFormData() {
    if (!this.formId) {
      return;
    }

    // ✅ 从共享存储读取最新数据（由主应用写入）
    const data: WidgetSongItem = await WidgetDataSync.getSongItem();

    const formData = formBindingData.createFormBindingData({
      name: data.name,
      artist: data.artist,
      isPlaying: data.isPlaying,
      pic: data.pic,
      currentTime: data.currentTime,
      duration: data.duration
    });

    formProvider.updateForm(this.formId, formData).then(() => {
      console.info(`Widget updated: ${data.name} - ${data.artist}, playing: ${data.isPlaying}`);
    }).catch((err: Error) => {
      console.error('Failed to update form data: ' + err.message);
    });
  }
}
