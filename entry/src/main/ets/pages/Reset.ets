import { logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlinkSpeed } from '../model/BlinkSpeed';

@Builder
export function ResetBuilder (){
  Reset()
}

@Component
struct Reset {
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {

     Column(){
       Blank().height('10%')
       Text('Restore default settings?').height('20%')
       Row(){
         Button(){
           Image($r('app.media.no')).width(20).height(20)
         }.backgroundColor('#dd393939').type(ButtonType.Circle).width(46).height(46)
           .onClick(()=>{

             this.pageInfos.removeByName('FlashlightSetting')
             this.pageInfos.removeByName('Reset')

             this.pageInfos.pushPathByName('FlashlightSetting',null,false);

             })
         Button(){
           Image($r('app.media.yes')).width(27).height(27)
         }.backgroundColor('#1C00E7').type(ButtonType.Circle).width(46).height(46)
         .align(Alignment.Center)
           .onClick(()=>{

             AppStorage.setOrCreate('selectedColorCode', '#fff');
             AppStorage.setOrCreate('selectedColorName', 'White');
             AppStorage.setOrCreate('flash', BlinkSpeed.OFF);

             this.pageInfos.replaceDestination({name: 'Flashlight',param: '#fff',
               onPop: (popInfo: PopInfo)=>{
                 logger.info(`[Reset][replaceDestination] last page is: ${popInfo.info.name}, result: ${JSON.stringify(popInfo.result)}`);
               }
             }).catch((error: BusinessError) => {
               logger.error(`[Reset][replaceDestination] failed, error code = ${error.code}, error.message = ${error.message}.`)
             }).then(() => {
               logger.error('[Reset][replaceDestination] success.');
             });

           })
       }.width('90%')
       .padding({bottom:10})
       .height('20%')
       .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceAround)
     }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
      .height('100%')
      .width('100%')

    }.width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}