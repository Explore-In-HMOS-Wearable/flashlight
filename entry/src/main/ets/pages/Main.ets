import { logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function MainBuilder (name: string, param: Object){
  Main()
}


@Component
struct Main {
  pageInfos: NavPathStack = new NavPathStack();
  @State colorCode: string | undefined = AppStorage.get('selectedColorCode')

  build() {
    NavDestination() {

      Column(){

        Column(){


        Row(){
          Image($r('app.media.flashlight')).fillColor(Color.White).height(75)
        }.height(100)
        .width(100)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Blue)
        .borderRadius(100)
        .clickEffect({level:ClickEffectLevel.LIGHT})
          .onClick(()=>{
            this.pageInfos.replaceDestination({name: 'Flashlight',param: this.colorCode,
            onPop: (popInfo: PopInfo)=>{
              logger.info(`[Main][replaceDestination] last page is: ${popInfo.info.name}, result: ${JSON.stringify(popInfo.result)}`);
            }
            }).catch((error: BusinessError) => {
              logger.error(`[Main][replaceDestination] failed, error code = ${error.code}, error.message = ${error.message}.`)
            }).then(() => {
              logger.error('[Main][replaceDestination] success.');
            });

          })

          Row(){


          }

        }.width('95%')
        .height('95%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

      }.width('100%')
      .height('100%')
      .linearGradient({
        colors: [
          ['#9c0054ff', 0.2],
          [Color.Black, 1.0]
        ]
      })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)


    }.width('100%')
    .height('100%')
    .gesture(
      PanGesture({
        direction: PanDirection.Up,
        distance: 5
      })
        .onActionEnd(() => {
         this.pageInfos.pushPathByName('FlashlightSetting',null,false)
        })
    )

    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })

  }

}