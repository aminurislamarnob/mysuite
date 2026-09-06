import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// The payload a Hugeicons glyph is described by.
///
/// Hugeicons ships each glyph as SVG path data rather than a font code point,
/// so it is a structure rather than an [IconData]. Aliasing it keeps that shape
/// out of every signature that just wants "an icon".
typedef HugeIconData = List<List<dynamic>>;

/// Draws a Hugeicons glyph with the same ambient behaviour as [Icon].
///
/// Two things [HugeIcon] does not do on its own are handled here:
///
///  * It hard-defaults its size to 24 and so never picks up the surrounding
///    [IconTheme] — resolving the theme is what lets glyphs inside [IconButton],
///    [ListTile] and the nav bar size themselves the way Material expects.
///  * Its glyph is an SVG, not a font glyph, so a tight parent constraint
///    stretches it to fill rather than leaving it at its own size. Centring it
///    the way [Icon] does keeps a 20px glyph 20px inside a 44px button.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticsLabel,
  });

  final HugeIconData icon;
  final double? size;
  final Color? color;

  /// Announced in place of the glyph. Supplied by forui's [FIcons] tokens, which
  /// label their icons for screen readers.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final dimension = size ?? iconTheme.size ?? 24;

    // Semantics adds no box of its own, so the sizing contract above is intact.
    Widget glyph = Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: dimension,
        child: HugeIcon(
          icon: icon,
          size: dimension,
          color: color ?? iconTheme.color,
        ),
      ),
    );

    if (semanticsLabel != null) {
      glyph = Semantics(label: semanticsLabel, child: glyph);
    }
    return glyph;
  }
}

/// Maps the icon tokens persisted in the database to concrete glyphs.
///
/// Icon choices are stored as stable strings rather than code points so that
/// swapping the icon set later never invalidates existing rows — as happened
/// when the app moved from Material icons to Hugeicons stroke-rounded.
class AppIcons {
  const AppIcons._();

  // chrome / navigation
  static const add = HugeIcons.strokeRoundedAdd01;
  static const addCircle = HugeIcons.strokeRoundedPlusSignCircle;
  static const back = HugeIcons.strokeRoundedArrowLeft01;
  static const chevronLeft = HugeIcons.strokeRoundedArrowLeft01;
  static const chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const arrowUp = HugeIcons.strokeRoundedArrowUp01;
  static const arrowDown = HugeIcons.strokeRoundedArrowDown01;
  static const close = HugeIcons.strokeRoundedCancel01;
  static const clear = HugeIcons.strokeRoundedCancel01;
  static const check = HugeIcons.strokeRoundedTick02;
  static const checkCircle = HugeIcons.strokeRoundedCheckmarkCircle02;
  static const circle = HugeIcons.strokeRoundedCircle;
  static const moreVertical = HugeIcons.strokeRoundedMoreVertical;
  static const moreHorizontal = HugeIcons.strokeRoundedMoreHorizontal;
  static const search = HugeIcons.strokeRoundedSearch01;
  static const searchOff = HugeIcons.strokeRoundedSearchRemove;
  static const filterOff = HugeIcons.strokeRoundedFilterRemove;
  static const edit = HugeIcons.strokeRoundedEdit02;
  static const delete = HugeIcons.strokeRoundedDelete02;
  static const deleteForever = HugeIcons.strokeRoundedDelete03;
  static const restore = HugeIcons.strokeRoundedDeletePutBack;
  static const archive = HugeIcons.strokeRoundedArchive02;
  static const unarchive = HugeIcons.strokeRoundedArchiveArrowUp;
  static const share = HugeIcons.strokeRoundedShare01;
  static const link = HugeIcons.strokeRoundedLink02;
  static const repeat = HugeIcons.strokeRoundedRepeat;
  static const replay = HugeIcons.strokeRoundedRefresh;
  static const transfer = HugeIcons.strokeRoundedExchange01;
  static const pin = HugeIcons.strokeRoundedPin;
  static const play = HugeIcons.strokeRoundedPlay;
  static const stop = HugeIcons.strokeRoundedStop;
  static const error = HugeIcons.strokeRoundedAlertCircle;
  static const warning = HugeIcons.strokeRoundedAlert02;
  static const info = HugeIcons.strokeRoundedInformationCircle;
  static const sparkle = HugeIcons.strokeRoundedSparkles;
  static const idea = HugeIcons.strokeRoundedBulb;
  static const trendUp = HugeIcons.strokeRoundedChartUp;
  static const trendDown = HugeIcons.strokeRoundedChartDown;
  static const percent = HugeIcons.strokeRoundedPercent;

  // Tokens forui's FIcons requires that had no semantic name here yet. Naming
  // them after the forui token keeps the mapping in app_forui_theme.dart obvious.
  static const chevronDown = HugeIcons.strokeRoundedArrowDown01;
  static const chevronUp = HugeIcons.strokeRoundedArrowUp01;
  static const chevronsUpDown = HugeIcons.strokeRoundedUnfoldMore;
  static const clock = HugeIcons.strokeRoundedClock01;
  static const eye = HugeIcons.strokeRoundedEye;
  static const eyeClosed = HugeIcons.strokeRoundedViewOffSlash;
  static const gripHorizontal = HugeIcons.strokeRoundedDragDropHorizontal;
  static const gripVertical = HugeIcons.strokeRoundedDragDropVertical;
  static const loader = HugeIcons.strokeRoundedLoading03;
  static const loaderCircle = HugeIcons.strokeRoundedLoading01;
  static const loaderPinwheel = HugeIcons.strokeRoundedLoading02;

  // shell destinations
  static const dashboard = HugeIcons.strokeRoundedDashboardSquare01;
  static const modules = HugeIcons.strokeRoundedDashboardSquare02;
  static const insights = HugeIcons.strokeRoundedAnalytics01;
  static const settings = HugeIcons.strokeRoundedSettings01;
  static const home = HugeIcons.strokeRoundedHome01;

  // notes & documents
  static const notes = HugeIcons.strokeRoundedNote01;
  static const note = HugeIcons.strokeRoundedStickyNote01;
  static const document = HugeIcons.strokeRoundedFile01;
  static const journal = HugeIcons.strokeRoundedBookOpen01;
  static const reading = HugeIcons.strokeRoundedBookOpen01;
  static const checklist = HugeIcons.strokeRoundedCheckList;
  static const people = HugeIcons.strokeRoundedUserGroup;
  static const family = HugeIcons.strokeRoundedUserGroup;
  static const person = HugeIcons.strokeRoundedUser;
  static const personAdd = HugeIcons.strokeRoundedUserAdd01;
  static const folder = HugeIcons.strokeRoundedFolder01;
  static const folderSpecial = HugeIcons.strokeRoundedFolder02;
  static const inbox = HugeIcons.strokeRoundedInbox;
  static const flag = HugeIcons.strokeRoundedFlag02;
  static const star = HugeIcons.strokeRoundedStar;
  static const heart = HugeIcons.strokeRoundedFavourite;
  static const tag = HugeIcons.strokeRoundedTag01;
  static const mic = HugeIcons.strokeRoundedMic01;
  static const micOff = HugeIcons.strokeRoundedMicOff01;
  static const gallery = HugeIcons.strokeRoundedImage02;
  static const camera = HugeIcons.strokeRoundedCamera01;
  static const scan = HugeIcons.strokeRoundedScan;
  static const pdf = HugeIcons.strokeRoundedPdf01;
  static const spreadsheet = HugeIcons.strokeRoundedTable01;
  static const backup = HugeIcons.strokeRoundedCloudUpload;
  static const restoreBackup = HugeIcons.strokeRoundedDatabaseRestore;

  // time & measurement
  static const today = HugeIcons.strokeRoundedCalendar01;
  static const calendar = HugeIcons.strokeRoundedCalendar03;
  static const calendarDone = HugeIcons.strokeRoundedCalendarCheckIn01;
  static const calendarRepeat = HugeIcons.strokeRoundedCalendarSetting01;
  static const calendarMonth = HugeIcons.strokeRoundedCalendar03;
  static const calendarWeek = HugeIcons.strokeRoundedCalendar02;
  static const alarm = HugeIcons.strokeRoundedAlarmClock;
  static const alarmAdd = HugeIcons.strokeRoundedAlarmClock;
  static const pending = HugeIcons.strokeRoundedTask01;
  static const focus = HugeIcons.strokeRoundedTimer02;
  static const session = HugeIcons.strokeRoundedTime04;
  static const timeline = HugeIcons.strokeRoundedChartLineData01;
  static const barChart = HugeIcons.strokeRoundedBarChart;
  static const pieChart = HugeIcons.strokeRoundedPieChart;

  // habits
  static const habits = HugeIcons.strokeRoundedCoffee02;
  static const tea = HugeIcons.strokeRoundedTea;
  static const water = HugeIcons.strokeRoundedDroplet;
  static const smoking = HugeIcons.strokeRoundedCigarette;
  static const exercise = HugeIcons.strokeRoundedDumbbell01;
  static const meditation = HugeIcons.strokeRoundedYoga01;
  static const sleep = HugeIcons.strokeRoundedMoon02;
  static const walk = HugeIcons.strokeRoundedWalking;
  static const study = HugeIcons.strokeRoundedSchool;
  static const music = HugeIcons.strokeRoundedMusicNote01;
  static const streak = HugeIcons.strokeRoundedFire;

  // money
  static const expenses = HugeIcons.strokeRoundedWallet01;
  static const bank = HugeIcons.strokeRoundedBank;
  static const card = HugeIcons.strokeRoundedCreditCard;
  static const cash = HugeIcons.strokeRoundedCash01;
  static const savings = HugeIcons.strokeRoundedSavings;
  static const bills = HugeIcons.strokeRoundedInvoice01;
  static const food = HugeIcons.strokeRoundedRestaurant01;
  static const dining = HugeIcons.strokeRoundedRestaurant02;
  static const transport = HugeIcons.strokeRoundedBus01;
  static const groceries = HugeIcons.strokeRoundedShoppingBasket01;
  static const shopping = HugeIcons.strokeRoundedShoppingBag02;
  static const cart = HugeIcons.strokeRoundedShoppingCart01;
  static const entertainment = HugeIcons.strokeRoundedFilm01;
  static const subscription = HugeIcons.strokeRoundedRepeat;
  static const work = HugeIcons.strokeRoundedBriefcase01;
  static const rocket = HugeIcons.strokeRoundedRocket01;
  static const travel = HugeIcons.strokeRoundedAirplane01;
  static const phone = HugeIcons.strokeRoundedSmartPhone01;
  static const otherCategory = HugeIcons.strokeRoundedGrid;

  // Further category glyphs, so a custom category can look like itself.
  static const coffee = HugeIcons.strokeRoundedCoffee02;
  static const sports = HugeIcons.strokeRoundedFootball;
  static const car = HugeIcons.strokeRoundedCar01;
  static const fuel = HugeIcons.strokeRoundedFuelStation;
  static const taxi = HugeIcons.strokeRoundedTaxi;
  static const house = HugeIcons.strokeRoundedHouse01;
  static const utilities = HugeIcons.strokeRoundedPlugSocket;
  static const electricity = HugeIcons.strokeRoundedFlash;
  static const internet = HugeIcons.strokeRoundedWifi01;
  static const laptop = HugeIcons.strokeRoundedLaptop;
  static const gift = HugeIcons.strokeRoundedGift;
  static const baby = HugeIcons.strokeRoundedBaby01;
  static const beauty = HugeIcons.strokeRoundedHairDryer;
  static const clothing = HugeIcons.strokeRoundedTShirt;
  static const insurance = HugeIcons.strokeRoundedShield01;
  static const tax = HugeIcons.strokeRoundedTaxes;
  static const investment = HugeIcons.strokeRoundedChartIncrease;
  static const charity = HugeIcons.strokeRoundedCharity;
  static const mosque = HugeIcons.strokeRoundedMosque01;
  static const games = HugeIcons.strokeRoundedGameController01;
  static const repairs = HugeIcons.strokeRoundedWrench01;
  static const laundry = HugeIcons.strokeRoundedWashingMachine;
  static const furniture = HugeIcons.strokeRoundedSofa01;
  static const stethoscope = HugeIcons.strokeRoundedStethoscope;
  static const moneyIn = HugeIcons.strokeRoundedMoneyReceive01;

  // medicine
  static const medicine = HugeIcons.strokeRoundedMedicine02;
  static const capsule = HugeIcons.strokeRoundedPill;
  static const syrup = HugeIcons.strokeRoundedDrink;
  static const injection = HugeIcons.strokeRoundedInjection;
  static const inhaler = HugeIcons.strokeRoundedLungs;
  static const prescription = HugeIcons.strokeRoundedPrescription;
  static const symptom = HugeIcons.strokeRoundedThermometer;
  static const inventory = HugeIcons.strokeRoundedPackage;

  // focus ambience
  static const forest = HugeIcons.strokeRoundedTree01;
  static const whiteNoise = HugeIcons.strokeRoundedAudioWave01;
  static const brownNoise = HugeIcons.strokeRoundedWave;
  static const ocean = HugeIcons.strokeRoundedBeach;

  // notifications
  static const notifications = HugeIcons.strokeRoundedNotification03;
  static const notificationsActive = HugeIcons.strokeRoundedNotification01;
  static const notificationsOff = HugeIcons.strokeRoundedNotificationOff03;

  // settings & accessibility
  static const palette = HugeIcons.strokeRoundedColors;
  static const themeMode = HugeIcons.strokeRoundedSun03;
  static const themeSystem = HugeIcons.strokeRoundedSmartPhone01;
  static const lightMode = HugeIcons.strokeRoundedSun03;
  static const darkMode = HugeIcons.strokeRoundedMoon02;
  static const compact = HugeIcons.strokeRoundedMenu02;
  static const reduceMotion = HugeIcons.strokeRoundedPauseCircle;
  static const textSize = HugeIcons.strokeRoundedTextFont;
  static const language = HugeIcons.strokeRoundedTranslate;
  static const biometric = HugeIcons.strokeRoundedFingerPrint;
  static const lock = HugeIcons.strokeRoundedLock;
  static const unlock = HugeIcons.strokeRoundedSquareUnlock01;
  static const privacy = HugeIcons.strokeRoundedShield01;
  static const quick = HugeIcons.strokeRoundedZap;

  // --- Module aliases ------------------------------------------------------
  // The remaining modules already read as their own name above: notes,
  // medicine, habits, expenses, focus.
  static const tasks = checkCircle;

  // --- Tokens persisted in the database ------------------------------------
  static const habitIcons = <String, HugeIconData>{
    'coffee': habits,
    'tea': tea,
    'water': water,
    'smoking': smoking,
    'exercise': exercise,
    'reading': reading,
    'meditation': meditation,
    'sleep': sleep,
    'walk': walk,
    'study': study,
    'music': music,
    'star': star,
  };

  static const categoryIcons = <String, HugeIconData>{
    'food': food,
    'dining': dining,
    'coffee': coffee,
    'groceries': groceries,
    'transport': transport,
    'car': car,
    'fuel': fuel,
    'taxi': taxi,
    'travel': travel,
    'bills': bills,
    'rent': house,
    'utilities': utilities,
    'electricity': electricity,
    'internet': internet,
    'phone': phone,
    'subscription': subscription,
    'shopping': shopping,
    'clothing': clothing,
    'gadgets': laptop,
    'furniture': furniture,
    'entertainment': entertainment,
    'games': games,
    'music': music,
    'sports': sports,
    'gym': exercise,
    'health': heart,
    'medical': stethoscope,
    'beauty': beauty,
    'education': study,
    'books': reading,
    'family': family,
    'kids': baby,
    'gift': gift,
    'charity': charity,
    'religion': mosque,
    'home': home,
    'repairs': repairs,
    'laundry': laundry,
    'insurance': insurance,
    'tax': tax,
    'savings': savings,
    'investment': investment,
    'other': otherCategory,
    'salary': cash,
    'freelance': work,
    'business': work,
    'bonus': moneyIn,
    'refund': moneyIn,
  };

  static const accountIcons = <String, HugeIconData>{
    'cash': cash,
    'bank': bank,
    'card': card,
    'bkash': phone,
    'nagad': phone,
    'rocket': rocket,
    'other': expenses,
  };

  static const medicineForms = <String, HugeIconData>{
    'tablet': medicine,
    'capsule': capsule,
    'syrup': syrup,
    'injection': injection,
    'drops': water,
    'inhaler': inhaler,
  };

  static const projectIcons = <String, HugeIconData>{
    'inbox': inbox,
    'home': home,
    'work': work,
    'folder': folder,
    'flag': flag,
    'heart': heart,
    'star': star,
  };

  static HugeIconData habit(String token) => habitIcons[token] ?? star;

  static HugeIconData category(String token) =>
      categoryIcons[token] ?? otherCategory;

  static HugeIconData account(String type) => accountIcons[type] ?? expenses;

  static HugeIconData medicineForm(String form) =>
      medicineForms[form] ?? medicine;

  static HugeIconData project(String token) => projectIcons[token] ?? folder;
}
