# RG-VWAPCross-MT5-Bot
Торговая система для MetaTrader 5, которая использует торговлю по VWAP

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* Version: 1.00

## Что нового?
```
1.00: Первая версия
```

## Стратегия бота

1.
2.

![Bot Layout](img/UM001.%20Layout.png)

## Установка

1. **Обновите терминал MetaTrader 5 до последней версии:** `Help->Check For Updates->Latest Release Version`. 
    - Если советник или индикатор не запускается, то проверьте сообщения на вкладке `Journal`. Возможно вы не обновили терминал до нужной версии.
    - Иногда для тестирования советников рекомендуется обновить терминал до самой последней бета-версии: `Help->Check For Updates->Latest Beta Version`. На прошлых версиях советник может не запускаться, потому что скомпилирован на последней версии терминала. В этом случае вы увидите сообщения на вкладке `Journal` об этом.
2. **Скопируйте файл бота `*.ex5` в каталог данных** терминала `MQL5\Experts\`. Открыть каталог данных терминала `File->Open Data Folder`.
3. **Установите из MQL5 Market индикатор `Structure Blocks`: https://www.mql5.com/ru/market/product/115943
8. **Откройте график нужной пары**.
9. **Переместите советника из окна `Навигатор` на график**.
10. **Установите в настройках бота галочку `Allow Auto Trading`**.
11. **Включите режим автоторговли** в терминале, нажав кнопку `Algo Trading` на главной панели инструментов.


## Техническое задание
- [x] 1. Expert start - 10:15 - Expert end 18:40 - 
- [ ] 2. if there are open positions, they need to be closed at the market price at 18:39, and stop to work after position close. Then on the next day it will start to work again by itself on 10:15.
Timeframe is M1


1. If the price is above VWAP

- [x] Then Expert need to place a limit order at the VWAP price -10 pips to buy, quantity = 3.
    Example: VWAP value is 107511, limit order to buy should be at price 107501.
    Only 1 active order is allowed.

- [x] 1.2 If the VWAP value has changed, then you need to cancel current the limit order to buy and make new VWAP value -10 pips to buy. VWAP value changes constantly, so expert needs to cancel and place new order frequently.

- [x] 1.3 If the order to buy was executed fully - then you need to immediately place an order to limit sell +40 pips from the purchase price (NOT Take profit, This is important!) and set Stop loss -10 pips from the purchase price. 
    Example: VWAP value is 107511, limit order to BUY should be at price 107501.
    This order is executed, now expert immediately places limit order to SELL, price = 107541 and Stop loss, price = 107491.
    ==Согласован вариант с SL и TP в позиции и без ордеров на уровнях SL и TP==

- [x]  1.3.1 While the position is open, you cannot open new positions to buy.

- [x] 1.4 If the stop loss was executed,

- [x] 1.4.1 Order to limit sell +40 pips from the purchase price should be cancelled.

- [x] 1.4.2 Then the Expert pauses for 15 minutes

- [x] 1.4.2 After the pause, if the price is above VWAP - then go to point 1 in this Specification after a pause, if the price is below VWAP, go to point 2 in this Specification.

 
- [x] 1.5 If the limit order to sell has been executed, then stop loss order should be cancelled, the Expert pauses for 5 minutes,
    After 5 minutes, if the price is above VWAP - then go to point 1 in this Specification after a pause, if the price is below VWAP, go to point 2 in this Specification.

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

 

 

- [ ] 2. If the price is below VWAP
 

3.      IMPORTANT

- [ ] I need to change all parameters, so I need full code:
- [ ] 1.      Expert start time
- [ ] 2.      Expert finish time
- [x] 3.      Pause time (now: 5 minutes after Limit profit order and 15 minutes after stop loss)
- [x] 4.      Value of the initial open buy or sell order (+10 or -10 relative to VWAP)
- [x] 5.      Value for limit profit order (now is 40) and stop loss (now is 10)
- [x] 6.      Quantity
- [x] 7.      Rounding. I may need to change the number of decimal places after rounding.


## Настройки бота

##### 1. SIGNAL (SIG)
- [x] `SIG_HTF`: SB Indicator TF for Structure Detect
- [x] `SIG_HTF_FF`: Entry Fibo zone level From
- [x] `SIG_HTF_FT`: Entry Fibo zone level To

- [x] `SIG_LTF`: SB Indicator TF for Structure Detect
- [x] `SIG_LTF_CMD`: Confirm Mode
- [x] `SIG_LTF_MACD_FEP`: MACD Fast EMA Period
- [x] `SIG_LTF_MACD_SEP`: MACD Slow EMA Period
- [x] `SIG_LTF_MACD_SP`: MACD Signal SMA Period

##### 2. FILTER IMPULSE PRICE ACTION (FIL)
- [x] `FIL_ENB`: Impulse Price Action Filter Enabled
- [x] `FIL_MFR`: Min Impulse Price Action Fibo Level
- [x] `FIL_SBD_MIN`: Min SB Depth allowed
- [x] `FIL_SBD_MAX`: Max SB Depth allowed

3. ENTRY (ENT)
- [x] `ENT_MMV`: Lot Size
- [x] `ENT_SL_ES`: SL Extra Shift, pnt

##### 5. MISCELLANEOUS (MS)
- [x] `MS_MGC`: Expert Adviser ID - Magic
- [x] `MS_EGP`: Expert Adviser Global Prefix
- [x] `MS_LOG_LL`: Log Level
- [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
- [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
- [x] `MS_PHV`: Print Historical Event Data
- [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
- [x] `MS_COM_IS`: Comment Interval, Sec
- [x] `MS_COM_EW`: Comment Custom Window


