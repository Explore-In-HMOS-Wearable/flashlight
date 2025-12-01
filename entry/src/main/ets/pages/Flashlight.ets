import { logger } from '../common/Logger';
import { BlinkSpeed } from '../model/BlinkSpeed';

@Builder
export function FlashlightBuilder (){
  Flashlight()
}

@Component
struct Flashlight {
  pageInfos: NavPathStack = new NavPathStack();
  @State originalColorCode: string = '';
  @State currentColor: string = '';
  @State currentSpeed: BlinkSpeed | undefined = AppStorage.get('flash');

  private intervalId: number | undefined = undefined;
  private readonly ALTERNATE_COLOR: string = '#000000';

  setBlinkSpeed(speed: BlinkSpeed) {
    this.stopBlinking();

    if (speed === BlinkSpeed.OFF) {
      this.currentColor = this.originalColorCode;
      this.currentSpeed = BlinkSpeed.OFF;
      logger.info(`[Flashlight] Blinking stopped.`);
      return;
    }

    this.currentSpeed = speed;

    logger.info(`[Flashlight] Blinking started with speed: ${speed}ms`);

    this.intervalId = setInterval(() => {
      if (this.currentColor === this.originalColorCode) {
        this.currentColor = this.ALTERNATE_COLOR;
      } else {
        this.currentColor = this.originalColorCode;
      }
    }, speed);
  }

  stopBlinking() {
    if (this.intervalId !== undefined) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
      this.currentSpeed = BlinkSpeed.OFF;
      this.currentColor = this.originalColorCode;
    }
  }

  build() {
    NavDestination() {
      Column(){


      }.width('100%')
      .height('100%')
      .backgroundColor(this.currentColor)

    }.width('100%')
    .height('100%')
    .hideTitleBar(true)
    .systemTransition(NavigationSystemTransitionType.NONE)
    .gesture(
      TapGesture()
        .onAction(() => {

          this.pageInfos.clear()

          this.pageInfos.pushPathByName('Main',null,false)

        })
    )
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;

      try {
        this.originalColorCode = (context.pathInfo.param as string);
        this.currentColor = this.originalColorCode;
        logger.info(`[Flashlight] color -> ${JSON.stringify(this.originalColorCode)}`);


         this.setBlinkSpeed(this.currentSpeed!);

      } catch (e) {
        logger.error(`[Flashlight] onReady catch exception: ${JSON.stringify(e)}`);
      }
    })
    .onDisAppear(() => {
      this.stopBlinking();
    });
  }

}