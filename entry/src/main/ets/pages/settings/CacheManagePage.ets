import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { CacheSet, CacheSetItem } from "../../common/entities/local/Settings"
import { Song } from "../../common/entities/song/Song"
import { changeSettings } from "../../common/functions/app/settings"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import FileUtils from "../../common/utils/file/FileUtils"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"

/**
 * 应用数据与缓存
 */
@Component
export struct CacheManagePage {
  @State cacheDirSize: number = -1
  @State songCacheSize: number = -1
  @StorageProp(StorageConstants.CACHE_SETTINGS) cacheSet: CacheSet = CacheSetItem
  @State set: CacheSet = CacheSetItem

  async aboutToAppear(): Promise<void> {
    this.set = this.cacheSet
    this.cacheDirSize = FileUtils.getCacheSize()
    this.songCacheSize = await FileUtils.getSongCacheSize()
  }

  private updateCacheSet() {
    this.cacheSet = this.set
    changeSettings(StorageConstants.CACHE_SETTINGS, this.cacheSet)
  }

  build() {
    NavDestination() {
      List({ space: Constants.PADDING_EDGE_DEFAULT }) {
        ListItem() {
          this.SetMaxCacheSize()
        }
        .itemStyle()

        ListItem() {
          Row(){
            Text('图片与下载临时文件')
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontWeight(FontWeight.Bold)
            Text(`${(this.cacheDirSize / (1024 * 1024)).toFixed(2)} MB`)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontWeight(FontWeight.Bold)
          }
          .height(Constants.HEIGHT_SETTINGS_ITEM)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
        }
        .itemStyle()

        ListItem() {
          Button($r('app.string.Clean_temp_cache'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontColor(Color.Red)
            .backgroundColor(Color.Transparent)
            .width('100%')
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
            .onClick(() => {
              this.showCacheDialog()
            })
        }
        .itemStyle()

        ListItem() {
          Button($r('app.string.Clean_persistent_data'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontColor(Color.Red)
            .backgroundColor(Color.Transparent)
            .width('100%')
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
            .onClick(() => {
              this.showCleanDialog()
            })
        }
        .itemStyle()
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.SET_DATAANDCACHE'))
    .backgroundColor($r('app.color.background'))
  }

  private showCacheDialog() {
    DialogUtil.showPrimaryDialog({
      title: '清理缓存',
      message: '这将清理应用临时缓存，不会影响本地曲库的歌曲\n\n请勿在下载过程中清理，否则可能导致下载中的歌曲异常',
      primaryButton: "取消",
      secondaryButton: {
        fontColor: Color.Red,
        value: '清理',
        action: async () => {
          try {
            const is = await FileUtils.removeCache()
            if (is) {
              ToastUtil.showToast('成功清理缓存目录')
            } else {
              ToastUtil.showToast('清理缓存目录失败')
            }
          } catch (e) {
            ToastUtil.showToast('清理缓存目录出错: ' + e)
          } finally {
            this.cacheDirSize = FileUtils.getCacheSize()
          }
        }
      }
    })
  }

  private showCleanDialog() {
    DialogUtil.showPrimaryDialog({
      title: '清理持久化数据',
      message: '如果应用遇到异常状况导致部分功能无法使用，你可以尝试清理持久化数据。\n这将会清空：\n\n1.播放列表数据\n2.上一次播放歌曲数据\n3.本地用户歌单、专辑、播客数据 (不会影响云端)',
      primaryButton: "取消",
      secondaryButton: {
        fontColor: Color.Red,
        value: '清理',
        action: async () => {
          try {
            await this.handleClean()
            ToastUtil.showToast('清理成功')
          } catch (e) {
            ToastUtil.showToast('清理持久化数据出错: ' + e)
          }
        }
      }
    })
  }

  private async handleClean() {
    await PlayQueueUtils.cleanQueue()
    PreferencesUtils.putPreferenceValue('Play','hasCurrentSong', false)
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, [])
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, [])
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
    let song: Song = {
      id: 0,
      name: "暂无播放",
      artists: [],
      album: {
        id: 0,
        name: '',
        picUrl: '',
        artists: [],
        size: 0
      },
      duration: 0,
      alias: [],
      fee: 0
    }
    let artists = '选择一首歌曲播放吧'
    let picUrl: string = ''
    let playMode: number = 0
    AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
    AppStorage.setOrCreate(StorageConstants.USER_DJRADIO_LIST, [])
    AppStorage.setOrCreate(StorageConstants.PLAY_MODE, playMode)
    AppStorage.setOrCreate(StorageConstants.PLAY_SONG, song)
    AppStorage.setOrCreate(StorageConstants.PLAY_ARTISTS, artists)
    AppStorage.setOrCreate(StorageConstants.PIC_URL, picUrl)
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }

  @Builder SetMaxCacheSize() {
    Column({ space: 5 }) {
      Row() {
        Text('歌曲最大缓存空间')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(`${this.cacheSet.songCacheMaxSize / (1024 * 1024 * 1024)} G`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
      }
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({
        value: this.set.songCacheMaxSize / (1024 * 1024 * 1024),
        min: 1,
        max: 20
      })
        .selectedColor($r('app.color.app_red'))
        .width('100%')
        .onChange((value, mode) => {
          if(mode == SliderChangeMode.Moving) {
            animateTo({ duration: 100, curve: Curve.Linear}, () => {
              this.set.songCacheMaxSize = value * 1024 * 1024 * 1024
            })
            return
          }
          this.cacheSet.songCacheMaxSize = value * 1024 * 1024 * 1024
          this.updateCacheSet()
        })
    }
    .width('100%')
  }
}

