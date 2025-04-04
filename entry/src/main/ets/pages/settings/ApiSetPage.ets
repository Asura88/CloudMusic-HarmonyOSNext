import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { checkValidUrl } from "../../common/functions/common/get"
import { openInWeb } from "../../common/functions/common/open"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../../components/buttons/ExplainButton"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct ApiSetPage {
  @StorageLink(StorageConstants.IS_CUSTOM_COOKIE) isCustomCookie: boolean = false
  @StorageProp(StorageConstants.CUSTOM_COOKIE) customCookie: string = ''
  @StorageProp(StorageConstants.API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Text() {
          Span(`用户云服务状态: `)
          Span(`${this.validApiUrl ? '正常' : '不可用'}`)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.validApiUrl ? Color.Green : $r('app.color.app_red'))
        }
        .width('100%')
        .fontColor($r('app.color.reverse'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding(Constants.PADDING_EDGE_DEFAULT)
        this.SetApiUrl()
        if(this.validApiUrl) {
          this.SetCookie()
        }
      }
      .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
      .width('100%')
      .constraintSize({
        minWidth: 200,
        maxWidth: 600
      })
    }
    .backgroundColor($r('app.color.background'))
    .title('云服务配置')
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('用户自定义云服务配置').LeftText()
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          TextInput({ text: this.customApiUrl })
            .layoutWeight(4)
            .onChange((text) => this.customApiUrl = text)
            .borderRadius(Constants.RADIUS_IMG)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomApiUrl()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .width('100%')
    }
    .itemStyle()
  }

  @Builder SetCookie() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('手动设置Cookie').LeftText()
          ExplainButton({ title: '手动设置Cookie',
            msg: '设置后每次API请求都将使用该Cookie, 包括登录、用户信息等获取, 重启后生效\n\n' +
              'Cookie只需要其中key为MUSIC_U的数据即可\n' +
              '例如: MUSIC_U=XXXXX'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomCookie })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomCookie(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if(this.isCustomCookie) {
        Column({ space: 10 }) {
          TextArea({ text: this.customCookie })
            .width('100%')
            .onChange((text) => this.customCookie = text)
            .borderRadius(Constants.RADIUS_IMG)
            .height(150)
            .textAlign(TextAlign.Start)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .width(100)
            .type(ButtonType.Normal)
            .borderRadius(Constants.RADIUS_BUTTON)
            .onClick(() => {
              this.setCustomCookie()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .itemStyle()
  }

  toggleCustomCookie(isOn: boolean) {
    this.isCustomCookie = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功')
    checkValidUrl()
  }

  setCustomCookie() {
    let cookie = this.customCookie.trim()
    if (!cookie.endsWith('; OS=pc')) {
      cookie += '; OS=pc'
    }
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, cookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_COOKIE, cookie)
    ToastUtil.showToast('设置成功')
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}