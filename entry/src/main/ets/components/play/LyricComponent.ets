import { EmitterUtil } from "@pura/harmony-utils"
import { Lyric } from "../../common/entities/song/Lyric"
import { seekMusic } from "../../common/functions/play/playControl"
import { LengthUnit } from "@kit.ArkUI"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { LyricStyle, LyricStyleItem } from "../../common/entities/local/Settings"
import LyricUtils from "../../common/utils/play/LyricUtils"

@Component
export struct LyricComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.CURRENT_LYRIC_INDEX) @Watch('ToCurrentLyric') currentLyricIndex: number = 0
  @State firstLoad: boolean = true
  @State userScrolling: number = 0
  @State userScrollingInterval: number = 0
  @State lyric: Lyric[] = []
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyleItem

  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    this.lyric = await LyricUtils.getLyricObjects()
    setTimeout(() => {
      this.scroller.scrollToIndex(this.currentLyricIndex, false, ScrollAlign.CENTER)
    }, 10)
    this.userScrollingInterval = setInterval(() => {
      if(this.userScrolling > 0) this.userScrolling -= 1
    }, 1000)
    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_LYRIC_UPDATE, async () => {
      this.lyric = await LyricUtils.getLyricObjects()
      this.currentLyricIndex = 0
    })
  }

  aboutToDisappear(): void {
    clearInterval(this.userScrollingInterval)
  }

  ToCurrentLyric() {
    if(!this.userScrolling) {
      this.scroller.scrollToIndex(this.currentLyricIndex, true, ScrollAlign.CENTER)
    }
  }

  build() {
    Stack() {
      List({ scroller: this.scroller, space: this.lyricStyle.size * 1.5 }) {
        ForEach(this.lyric, (item: Lyric, index) => {
          ListItem() {
            LyricLine({
              lyricStyle: this.lyricStyle,
              currentLyricIndex: this.currentLyricIndex,
              userScrolling: this.userScrolling,
              index: index,
              item: item
            })
          }
        })
      }
      .padding({ top: 30 })
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)
      .scrollSnapAlign(ScrollSnapAlign.CENTER)
      .scrollBar(BarState.Off)
      .chainAnimation(true)
      .fadingEdge(true, {
        fadingEdgeLength: {
          unit: LengthUnit.PERCENT,
          value: 40
        }
      })
      .onTouch(() => {
        this.userScrolling = 2
      })
    }
  }
}

@Reusable
@Component struct LyricLine {
  @State index: number = 0
  @State item: Lyric = { time: 0, content: ''}
  @Prop currentLyricIndex: number = 0
  @Prop lyricStyle: LyricStyle = LyricStyleItem
  @Link userScrolling: number

  aboutToReuse(params: ESObject): void {
    this.index = params.index
    this.item = params.item as Lyric
  }

  build() {
    Text(this.item.content)
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(this.lyricStyle.size)
      .lineHeight(this.lyricStyle.size * 1.3)
      .fontColor(this.index === this.currentLyricIndex ? this.lyricStyle.color : Color.White)
      .opacity(this.index == this.currentLyricIndex ? 1 : 0.35)
      .fontWeight(this.index === this.currentLyricIndex ? FontWeight.Bolder : FontWeight.Bold)
      .textAlign(this.lyricStyle.align === 'center' ? TextAlign.Center : TextAlign.Start)
      .scale(this.index === this.currentLyricIndex ?
        { x: 1.0, y: 1.0, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 } :
        { x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 })
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
      .padding({ left: 20, right: 20 })
      .onClick(() => {
        this.userScrolling = 0
        seekMusic(this.item.time)
      })
      .animation({
        duration: 600,
        curve: Curve.Smooth,
        expectedFrameRateRange: {
          expected: 120,
          min: 60,
          max: 120
        }
      })
  }
}
