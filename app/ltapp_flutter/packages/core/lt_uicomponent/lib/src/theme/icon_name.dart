enum IconName {
  downArrowFill,
  calendar,
  deselectedCalendar,
  threads,
  deselectedThread,
  insights,
  deselectedInsights,
  user,
  deselectedUser,
  star,
  smallCross,
  close,
  refresh,
}

extension IconNameExtension on IconName {
  String get fileName {
    switch (this) {
      case IconName.downArrowFill:
        return "down_arrow_fill.svg";
      case IconName.calendar:
        return "calendar_icon.svg";
      case IconName.threads:
        return "Threads.svg";
      case IconName.deselectedThread:
        return "deselectedThread.svg";
      case IconName.deselectedCalendar:
        return "deselectedCalendar.svg";
      case IconName.insights:
        return "insights.svg";
      case IconName.deselectedInsights:
        return "deselected_insights.svg";
      case IconName.user:
        return "user.svg";
      case IconName.deselectedUser:
        return "deselected_user.svg";
      case IconName.star:
        return "Star.svg";
      case IconName.smallCross:
        return "small_cross.svg";
      case IconName.close:
        return "close.svg";
      case IconName.refresh:
        return "refresh.svg";
    }
  }
}
