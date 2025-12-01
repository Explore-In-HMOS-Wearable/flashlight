import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, CircleShape, ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlinkSpeed } from '../model/BlinkSpeed';

@Builder
export function FlashBuilder (){
  Flash()
}

interface CustomButtonType {
  title:string;
  isSelected:boolean;
}

@Builder
function buildText() {
  Column() {
    Text('Flash')
      .fontSize('40px')
      .width('50%')
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
  }.margin(0)
}

@Component
struct Flash {
  pageInfos: NavPathStack = new NavPathStack();

  private watchSize: string = '466px';
  context: UIContext = this.getUIContext();
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));
  @State colorCode: string | undefined = AppStorage.get('selectedColorCode')
  flash: BlinkSpeed | undefined = AppStorage.get('flash')


  @State options:CustomButtonType[] = [
    {title:'None', isSelected: (this.flash === BlinkSpeed.OFF) ? true : false},
    {title:'Slow', isSelected: (this.flash === BlinkSpeed.SLOW) ? true : false},
    {title:'Fast', isSelected: (this.flash === BlinkSpeed.FAST) ? true : false}
  ]

  @Builder
  buildList2() {
    Stack() {
      Column() {
      }
      .justifyContent(FlexAlign.Center)
      .width(this.watchSize)
      .height(this.watchSize)
      .clipShape(new CircleShape({ width: '100%', height: '100%' }))

      ArcList({ initialIndex: 0, header: this.tabBar1 }) {
        ForEach(this.options, (item: CustomButtonType) => {
          ArcListItem() {

            Button({type: ButtonType.Capsule }){

              Row(){

                Stack() {


                  Text(item.title)
                    .fontSize('38px')
                    .width('100%')

                  Radio({ value: item.title, group: 'radioGroup',
                    indicatorType:RadioIndicatorType.DOT
                  }).checked(item.isSelected)
                    .height(50)
                    .width(80)
                    .onChange((isChecked: boolean) => {
                      item.isSelected = isChecked
                      if (isChecked) {

                        if (item.title === 'Fast') {
                          AppStorage.setOrCreate('flash', BlinkSpeed.FAST);
                        } else if (item.title === 'Slow') {
                          AppStorage.setOrCreate('flash', BlinkSpeed.SLOW);
                        } else {
                          AppStorage.setOrCreate('flash', BlinkSpeed.OFF);
                        }

                      }
                      this.pageInfos.clear()
                      this.pageInfos.replaceDestination({name: 'Flashlight',param: this.colorCode,
                        onPop: (popInfo: PopInfo)=>{
                          logger.info(`[Flash][replaceDestination] last page is: ${popInfo.info.name}, result: ${JSON.stringify(popInfo.result)}`);
                        }
                      }).catch((error: BusinessError) => {
                        logger.error(`[Flash][replaceDestination] failed, error code = ${error.code}, error.message = ${error.message}.`)
                      }).then(() => {
                        logger.error('[Flash][replaceDestination] success.');
                      });
                    })
                    .width(30)
                    .height(30)


                }.alignContent(Alignment.End)

              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')

            }
            .width('92%')
            .height('120px')
            .fontSize('40px')
            .focusable(true)
            .focusOnTouch(true)
            .backgroundColor('#ff2b2b2b')



          }.align(Alignment.Center)
        }, (item: CustomButtonType, index: number) => {return index + '_' + JSON.stringify(item.title); })
      }
      .space(LengthMetrics.px(10))
      .borderRadius(this.watchSize)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
    }
    .align(Alignment.Center)
    .width(this.watchSize)
    .height(this.watchSize)
    .border({color: Color.Black, width: 1})
    .borderRadius(this.watchSize)
  }

  build() {
    NavDestination() {

      Column(){

        this.buildList2()


      }.alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height('100%')

    }.width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}