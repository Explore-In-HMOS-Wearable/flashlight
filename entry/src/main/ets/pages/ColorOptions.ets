import { logger } from '../common/Logger';
import ColorType from '../model/ColorType';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function ColorOptionsBuilder(){
  ColorOptions()
}

@Component
export default struct ColorOptions {
  pageInfos: NavPathStack = new NavPathStack();
  @State selectedColorIndex: number | undefined = AppStorage.get('selectedColorIndex');

  colorList: ColorType[] = [
    { colorCode: '#fff', colorIndex: 0, colorName: 'White' },
    { colorCode: '#df2d4f', colorIndex: 1, colorName: 'Red' },
    { colorCode: '#FE8319', colorIndex: 2, colorName: 'Orange' },
    { colorCode: '#FCBF02', colorIndex: 3, colorName: 'Gold' },
    { colorCode: '#64BB5D', colorIndex: 4, colorName: 'Green' },
    { colorCode: '#00A4AD', colorIndex: 5, colorName: 'Teal' },
    { colorCode: '#2780FF', colorIndex: 6, colorName: 'Blue' },
    { colorCode: '#964CD7', colorIndex: 7, colorName: 'Purple' },
    { colorCode: 'None', colorIndex: 8, colorName: 'Custom' }
  ];


  scroller: Scroller = new Scroller();

  build() {
      NavDestination(){

        Column(){

          Grid(this.scroller) {
            ForEach(this.colorList, (color: ColorType) => {
              GridItem() {

                Stack(){
                  if (color.colorIndex === this.selectedColorIndex) {
                    Image($r('app.media.circle')).height(58).width(58)
                  }
                  Circle().backgroundImage($r('app.media.spectrum')).backgroundImagePosition(Alignment.Center)
                    .borderRadius(100).fill((color.colorName !== 'Custom') ? color.colorCode : Color.Transparent).height(43).width(43).clickEffect({level:ClickEffectLevel.MIDDLE})
                    .onClick(()=>{
                      this.selectedColorIndex = color.colorIndex;
                      if (color.colorIndex === 8) {
                        this.pageInfos.pushPathByName('CustomColorPicker',null,false)
                      } else {

                        this.pageInfos.clear()
                        AppStorage.setOrCreate('selectedColorIndex', this.selectedColorIndex);
                        AppStorage.setOrCreate('selectedColorCode', color.colorCode);
                        AppStorage.setOrCreate('selectedColorName', color.colorName);

                        this.pageInfos.replaceDestination({name: 'Flashlight',param: color.colorCode,
                          onPop: (popInfo: PopInfo)=>{
                            logger.info(`[CustomColorPicker][replaceDestination] last page is: ${popInfo.info.name}, result: ${JSON.stringify(popInfo.result)}`);
                          }
                        }).catch((error: BusinessError) => {
                          logger.error(`[CustomColorPicker][replaceDestination] failed, error code = ${error.code}, error.message = ${error.message}.`)
                        }).then(() => {
                          logger.error('[CustomColorPicker][replaceDestination] success.');
                        });

                      }
                    })
                }
                .height(60).width(60)
                .alignContent(Alignment.Center)


              }
            }, (item: ColorType, index: number) => {return item.colorCode})
          }
          .columnsTemplate('1fr 1fr 1fr')
          .enableScrollInteraction(false)
          .supportAnimation(false)
          .multiSelectable(false)
          .width('80%')
          .height('80%')

        }.width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)

      }.width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .hideTitleBar(true)
      .onReady((context: NavDestinationContext) => {
        this.pageInfos = context.pathStack;
      })
  }
}
