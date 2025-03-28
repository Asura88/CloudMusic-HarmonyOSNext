import { CacheManagePage} from './CacheManagePage'
import { VersionCard } from '../../components/settings/TextContent'
import Constants from '../../common/constants/Constants'
import { SetDefaultHomePage } from '../../components/settings/SetDefaultHomePage'
import { SongClickActionPage } from './SongClickActionPage'
import { ApiSetPage } from './ApiSetPage'
import { WebPage } from '../WebPage'
import { WebPageParam } from '../../common/entities/PageParams'
import { DebugPage } from '../DebugPage'
import { CommonSettingsCard } from '../../components/cards/SettingsCard'
import { PlaySettingsPage } from './PlaySettingsPage'
import { AboutPage } from './AboutPage'
import { DonatePage } from './DonatePage'

/**
 * 设置页面
 */
@Component
export struct SettingsPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Provide('settingsPageInfos') settingsPageInfos: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.settingsPageInfos) {
      Stack() {
        Scroll() {
          Column({ space: 10 }) {
            List({ space: 10 }) {
              ListItemGroup() {
                SetDefaultHomePage()
              }
              .listItemGroupStyle()

              ListItemGroup() {
                this.PlaySettings()
              }
              .listItemGroupStyle()

              ListItemGroup() {
                this.MainSettings()
              }
              .listItemGroupStyle()

              ListItemGroup() {
                VersionCard()

                CommonSettingsCard({
                  title: '使用文档',
                  action: () => {
                    let param: WebPageParam = {
                      title: '使用文档', url: 'https://docs.chenlvin.cc/cloudmusic/#/help'
                    }
                    this.settingsPageInfos.pushPathByName('WebPage', param)
                  }
                })
              }
              .listItemGroupStyle()

              ListItem().height(px2vp(this.bottomRectHeight))
            }
            .scrollBar(BarState.Auto)
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
        }
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background'))
    .title('设置')
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(this.PageMap)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SongClickActionPage') {
      SongClickActionPage()
    }
    else if(name === 'PlaySettingsPage') {
      PlaySettingsPage()
    }
    else if(name === 'ApiSetPage') {
      ApiSetPage()
    }
    else if(name === 'CacheManagePage') {
      CacheManagePage()
    }
    else if(name === 'WebPage') {
      WebPage({ param: param as WebPageParam })
    }
    else if(name === 'AboutPage') {
      AboutPage()
    }
    else if(name === 'DonatePage') {
      DonatePage()
    }
    else if(name === 'DebugPage') {
      DebugPage()
    }
  }

  @Builder PlaySettings() {
    ListItem() {
      CommonSettingsCard({
        title: '播放设置',
        action: () => {
          this.settingsPageInfos.pushPathByName('PlaySettingsPage', null)
        }
      })
    }
    ListItem() {
      CommonSettingsCard({
        title: '歌曲卡片设置',
        action: () => {
          this.settingsPageInfos.pushPathByName('SongClickActionPage', null)
        }
      })
    }
  }

  @Builder MainSettings() {
    ListItem() {
      CommonSettingsCard({
        title: '在线服务设置',
        action: () => {
          this.settingsPageInfos.pushPathByName('ApiSetPage', null)
        }
      })
    }
    ListItem() {
      CommonSettingsCard({
        title: '应用缓存',
        action: () => {
          this.settingsPageInfos.pushPathByName('CacheManagePage', null)
        }
      })
    }
  }
}

@Extend(ListItemGroup) function listItemGroupStyle() {
  .divider({ strokeWidth: 0.1, startMargin: 10, endMargin: 10, color: Color.Gray })
  .backgroundColor($r('app.color.main'))
  .borderRadius(Constants.RADIUS_CARD)
  .margin({ left: 20, right: 20 })
  .padding({
    left: Constants.PADDING_EDGE_DEFAULT,
    right: Constants.PADDING_EDGE_DEFAULT,
    top: Constants.PADDING_INNER_DEFAULT,
    bottom: Constants.PADDING_INNER_DEFAULT
  })
  .constraintSize({
    minHeight: 60,
    maxHeight: '100%'
  })
}

