import { image } from '@kit.ImageKit';
import { logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function CustomColorPickerBuilder(){
  CustomColorPicker()
}

@Component
struct CustomColorPicker {
  pageInfos: NavPathStack = new NavPathStack();


  @State pickedHex: string | undefined = AppStorage.get('selectedColorCode')
  private pixelMap?: image.PixelMap
  private srcWpx: number = 0
  private srcHpx: number = 0
  private renderWpx: number = 0
  private renderHpx: number = 0


  build() {

    NavDestination(){


      Row() {
        Image($r('app.media.spectrum'))
          .width(160)
          .height(160)
          .borderRadius(100)
          .objectFit(ImageFit.Contain)
          .alignSelf(ItemAlign.Center)
          .onAreaChange((_, geom) => {
            const w = Number(geom.width)
            const h = Number(geom.height)
            if (!Number.isNaN(w) && !Number.isNaN(h)) {
              this.renderWpx = Math.max(1, Math.round(w))
              this.renderHpx = Math.max(1, Math.round(h))
              console.info(`area render(px): ${this.renderWpx} x ${this.renderHpx}`)
            }
          })
          .gesture(
            PanGesture({ fingers: 1 })
              .onActionUpdate((evt: GestureEvent) => this.onTap(evt))
              .onActionEnd((evt: GestureEvent) => this.onTap(evt))
          )

        Column(){

          Stack(){
              Image($r('app.media.circle')).height(40).width(40)
            Circle().borderRadius(100).fill(this.pickedHex).height(30).width(30)

          }
          .height(40).width(40)
          .margin({right:25})
          .alignContent(Alignment.Center)

          Button(){
            Image($r('app.media.white_no')).width(16).height(16)
          }.backgroundColor('#dd393939').type(ButtonType.Circle).width(40).height(40)
            .onClick(()=>{
              // TODO
              this.pageInfos.clear()
              this.pageInfos.pushPathByName('ColorOptions',null,false);
            }).margin({left:15})

          Button(){
            Image($r('app.media.yes')).width(20).height(20)
          }.backgroundColor('#dd393939').type(ButtonType.Circle).width(40).height(40)
            .onClick(()=>{

              AppStorage.setOrCreate('selectedColorIndex', 8);
              AppStorage.setOrCreate('selectedColorCode', this.pickedHex);
              AppStorage.setOrCreate('selectedColorName', 'Custom');

              this.pageInfos.replaceDestination({name: 'Flashlight',param: this.pickedHex,
                onPop: (popInfo: PopInfo)=>{
                  logger.info(`[CustomColorPicker][replaceDestination] last page is: ${popInfo.info.name}, result: ${JSON.stringify(popInfo.result)}`);
                }
              }).catch((error: BusinessError) => {
                logger.error(`[CustomColorPicker][replaceDestination] failed, error code = ${error.code}, error.message = ${error.message}.`)
              }).then(() => {
                logger.error('[CustomColorPicker][replaceDestination] success.');
              });           })
            .margin({right:25})


        }.height('70%')
        .justifyContent(FlexAlign.SpaceAround)
        .width(45)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)





    }.width('100%')
    .height('100%')
    .align(Alignment.Center)
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onReady(async (context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;


      try {
        const rm = this.getUIContext().getHostContext()!.resourceManager
        const resId: number = $r('app.media.spectrum').id

        const bytes: Uint8Array = await rm.getMediaContent(resId)
        const src: image.ImageSource = image.createImageSource(bytes.buffer as ArrayBuffer)

        this.pixelMap = await src.createPixelMap()
        const info = await this.pixelMap.getImageInfo()
        this.srcWpx = info.size.width
        this.srcHpx = info.size.height

        console.info(`PixelMap ready: src=${this.srcWpx}x${this.srcHpx}px`)
      } catch (e) {
        console.error('Image load error:', (e as Error).message)
      }


    })

  }


  private contentRectPx(): RectPx {
    const rw = Math.max(1, Math.round(this.renderWpx))
    const rh = Math.max(1, Math.round(this.renderHpx))

    const arSrc = (this.srcWpx > 0 && this.srcHpx > 0) ? (this.srcWpx / this.srcHpx) : 1
    const arRend = rw / rh

    if (arSrc >= arRend) {
      const cw = rw
      const ch = Math.max(1, Math.round(cw / arSrc))
      const top = Math.round((rh - ch) / 2)
      return new RectPx(0, top, cw, ch)
    } else {
      const ch = rh
      const cw = Math.max(1, Math.round(ch * arSrc))
      const left = Math.round((rw - cw) / 2)
      return new RectPx(left, 0, cw, ch)
    }
  }

  private async readPixelRGBA(cx: number, cy: number): Promise<RGBA> {
    const info = await this.pixelMap!.getImageInfo()
    const w = info.size.width
    const h = info.size.height

    const buf = new ArrayBuffer(w * h * 4)
    await this.pixelMap!.readPixelsToBuffer(buf)

    const u8 = new Uint8Array(buf)
    const idx = (cy * w + cx) * 4
    return { r: u8[idx], g: u8[idx + 1], b: u8[idx + 2], a: u8[idx + 3] }
  }

  private toHexByte(n: number): string {
    return n.toString(16).padStart(2, '0')
  }

  async onTap(evt?: GestureEvent) {
    if (!this.pixelMap || !evt || !evt.fingerList || evt.fingerList.length === 0) {
      return
    }
    if (this.renderWpx <= 0 || this.renderHpx <= 0 || this.srcWpx <= 0 || this.srcHpx <= 0) {
      console.warn('sizes not ready')
      return
    }

    const p = evt.fingerList[0]
    const rect = this.contentRectPx()

    if (
      p.localX < rect.left || p.localX > rect.left + rect.width ||
        p.localY < rect.top  || p.localY > rect.top  + rect.height
    ) {
      console.info('tap outside content; ignoring')
      return
    }

    const nx = (p.localX - rect.left) / rect.width
    const ny = (p.localY - rect.top)  / rect.height
    let cx = Math.round(nx * (this.srcWpx - 1))
    let cy = Math.round(ny * (this.srcHpx - 1))
    if (cx < 0) {
      cx = 0
    }
    if (cy < 0) {
       cy = 0
    }
    if (cx >= this.srcWpx) {
       cx = this.srcWpx - 1
    }
    if (cy >= this.srcHpx) {
      cy = this.srcHpx - 1
    }

    try {
      const pixel = await this.readPixelRGBA(cx, cy)
      const r = pixel.r
      const g = pixel.g
      const b = pixel.b

      this.pickedHex = `#${this.toHexByte(r)}${this.toHexByte(g)}${this.toHexByte(b)}`
      console.info(`pick px=(${cx},${cy}) norm=(${nx.toFixed(3)},${ny.toFixed(3)}) hex=${this.pickedHex}`)
    } catch (e) {
      console.error('readPixelRGBA error:', (e as Error).message)
    }
  }

}



interface RGBA {
  r: number
  g: number
  b: number
  a: number
}

class RectPx {
  left: number
  top: number
  width: number
  height: number
  constructor(left: number, top: number, width: number, height: number) {
    this.left = left
    this.top = top
    this.width = width
    this.height = height
  }
}
