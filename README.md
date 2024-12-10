# RG-VWAPCross-MT5-Bot
Торговая система для MetaTrader 5, которая использует торговлю от VWAP

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* Version: 1.00

## Что нового?
```
1.00: Релиз
```

## Установка

1. **Обновите терминал MetaTrader 5 до последней версии:** `Help->Check For Updates->Latest Release Version`. 
    - Если советник или индикатор не запускается, то проверьте сообщения на вкладке `Journal`. Возможно вы не обновили терминал до нужной версии.
    - Иногда для тестирования советников рекомендуется обновить терминал до самой последней бета-версии: `Help->Check For Updates->Latest Beta Version`. На прошлых версиях советник может не запускаться, потому что скомпилирован на последней версии терминала. В этом случае вы увидите сообщения на вкладке `Journal` об этом.
2. **Скопируйте файл бота `*.ex5` в каталог данных** терминала `MQL5\Experts\`. Открыть каталог данных терминала `File->Open Data Folder`.
3. **Установите из MQL5 Market индикатор `Daily VWAP Indicator`**: https://www.mql5.com/ru/market/product/126027
8. **Откройте график нужной пары**.
9. **Переместите советника из окна `Навигатор` на график**.
10. **Установите в настройках бота галочку `Allow Auto Trading`**.
11. **Включите режим автоторговли** в терминале, нажав кнопку `Algo Trading` на главной панели инструментов.


## Техническое задание
- [x] 1. Expert start - 10:15 - Expert end 18:40
    > Use `FIL_TIM_FR` and `FIL_TIM_TO` params
- [x] 2. if there are open positions, they need to be closed at the market price at 18:39, and stop to work after position close. Then on the next day it will start to work again by itself on 10:15.
    > Use `FIL_EXT_HCT` param

- [x] Timeframe is M1
    > The bot uses current chart TF to trade. Set M1 to update orders every 1 min by VWAP indicator value as agreed (https://www.mql5.com/ru/job/229538/discussion?id=1111560&comment=55336659)

1. **If the price is above VWAP**

- [x] Then Expert need to place a limit order at the VWAP price -10 pips to buy, quantity = 3.
    Example: VWAP value is 107511, limit order to buy should be at price 107501.
    > Use `ENT_OEP` to set EP shift in points  and `ENT_MMV` to set lot size.
    > You can use different indicators as signal. Just set `IND_NAM` and `IND_BUF` params.
- [x] Only 1 active order is allowed.
    > Every bar bot deletes order in market and open new one.
    
- [x] 1.2 If the VWAP value has changed, then you need to cancel current the limit order to buy and make new VWAP value -10 pips to buy. VWAP value changes constantly, so expert needs to cancel and place new order frequently.
    > Every bar bot deletes order in market and open new one.

- [x] 1.3 If the order to buy was executed fully - then you need to immediately place an order to limit sell +40 pips from the purchase price (NOT Take profit, This is important!) and set Stop loss -10 pips from the purchase price. 
    Example: VWAP value is 107511, limit order to BUY should be at price 107501.
    This order is executed, now expert immediately places limit order to SELL, price = 107541 and Stop loss, price = 107491.
    > The bot puts order with fixed SL and TP without using pending orders to close on TP and SL levels (agreed: https://www.mql5.com/ru/job/229538/discussion?id=1111560&comment=55337466)

- [x]  1.3.1 While the position is open, you cannot open new positions to buy.
    > By default if there's any pos in market bot skips orders. But you can use `FIL_ADD' param to allow to bot opens positions in different directions. Any way only one pos in one dir is allowed.

- 1.4 If the stop loss was executed,

- [x] 1.4.1 Order to limit sell +40 pips from the purchase price should be cancelled.
    > Bot doesn't use pending orders to exit pos by SL or TP as agreed https://www.mql5.com/ru/job/229538/discussion?id=1111560&comment=55337466

- [x] 1.4.2 Then the Expert pauses for 15 minutes
    > Use `FIL_PTM_SL` or '`FIL_PTM_TP` to change pause duration.

- [x] 1.4.2 After the pause, if the price is above VWAP - then go to point 1 in this Specification after a pause, if the price is below VWAP, go to point 2 in this Specification.
    > Done

 
- [x] 1.5 If the limit order to sell has been executed, then stop loss order should be cancelled, the Expert pauses for 5 minutes,
    After 5 minutes, if the price is above VWAP - then go to point 1 in this Specification after a pause, if the price is below VWAP, go to point 2 in this Specification.
    > Use `FIL_PTM_SL` or '`FIL_PTM_TP` to change pause duration.

- [x] 1.6 If order executed partially:
    Remaining part of order must be active.
    For example, there was an order to buy 3 contracts (=quantity) at a price of 99,000.
    The Expert bought 1 contract.
    Then the order must remain unchanged: 2 contracts at a price of 99,000, even if VWAP has changed.
    For an open position, Stop loss -10 pip and limit Take Profit + 40 pip orders must be immediately placed.
    In this example, the quantity will be 1 contract.
    If Limit Take profit for 1 contract is executed, opened order need to be cancelled, then the Expert pauses for 5 minutes.
    After 5 minutes, if the price is above VWAP - then go to point 1 in this Specification after a pause, if the price is below VWAP, go to point 2 in this Specification.
    If Stop loss is executed, this will mean that the purchase order has been fully triggered. Limit order to sell is cancelled, The Expert pauses for 15 minutes.
    Overall, the logic is that there should not be open positions in the portfolio of more than 3 contracts.
    > Bot doesn't use pending orders to exit pos by SL or TP. So if pos was not fulfilled it stays in market with lower lots size (as agreed https://www.mql5.com/ru/job/229538/discussion?id=1111560&comment=55337466)

 
- [x] 2. If the price is below VWAP
    > All the same with BUY
 

3.      IMPORTANT

- [x] I need to change all parameters, so I need full code:
- [x] 1.      Expert start time
- [x] 2.      Expert finish time
- [x] 3.      Pause time (now: 5 minutes after Limit profit order and 15 minutes after stop loss)
- [x] 4.      Value of the initial open buy or sell order (+10 or -10 relative to VWAP)
- [x] 5.      Value for limit profit order (now is 40) and stop loss (now is 10)
- [x] 6.      Quantity
- [x] 7.      Rounding. I may need to change the number of decimal places after rounding.
    > The bot uses rounding set in Symbol Specification of your terminal.


## Настройки бота


##### 1. INDICATOR (IND)
- [x] `IND_NAM`: Путь до файла индикатора без расширения
    - если индикатор установлен из Маркета, то нужно указать путь `Market\\<имя файла индикатора без расширения>`;
    - если индикатор установлен в папке `Indicators` каталога данных терминала, то нужно указать просто имя файла индикатора без расширения.
- [x] `IND_BUF`: Номер буфера индикатора
    - Какой по счету номер буфера должен использовать бот. В `Daily VWAP Indicator` буфер всего один, поэтому его номер равен 0. 
    - Для других индикаторов укажите нужный номер буфера.
- [x] `IND_APP`: Price type - *будет передан выбранному индикатору первым параметром*
- [x] `IND_APV`: Volume type - *будет передан выбранному индикатору первым параметром*

##### 2. ENTRY (ENT)
- [x] `ENT_MMV`: Lot Size
- [x] `ENT_OEP`: Сдвиг EP LIMIT ордера от индикатора, пункт
- [x] `ENT_OSL`: Дистанция SL LIMIT ордера от EP, пункт
- [x] `ENT_OTP`: Дистанция TP LIMIT ордера от EP, пункт

##### 3. FILTER (FIL)
- [x] `FIL_TIM_FR`: Время начала работы 'ЧЧ:ММ' (пусто-откл)
- [x] `FIL_TIM_TO`: Время окончания работы 'ЧЧ:ММ' (пусто-откл)
- [x] `FIL_PTM_SL`: Длительность паузы после SL, мин (0-откл)
- [x] `FIL_PTM_TP`: Длительность паузы после TP, мин (0-откл)
- [x] `FIL_ADD`: Разрешить несколько позиций (в разных направлениях)

##### 4. EXIT (EXT)
- [x] `FIL_EXT_HCT`: После этого времени закрывать позиции 'ЧЧ:ММ' (пусто-откл)

##### 5. MISCELLANEOUS (MS)
- [x] `MS_MGC`: Expert Adviser ID - Magic
- [x] `MS_EGP`: Expert Adviser Global Prefix
- [x] `MS_LOG_LL`: Log Level
- [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
- [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
- [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
- [x] `MS_COM_IS`: Comment Interval, Sec

