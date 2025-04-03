import 'package:flutter/cupertino.dart';

class JoblistNavigationViewModel extends ChangeNotifier{
  int _joblistIndex = 0;
  final PageController _joblistController = PageController();

  int get joblistIndex => _joblistIndex;
  PageController get joblistController => _joblistController;

  void onTapAppliedJob_FavJob(int index) {
    if (_joblistIndex != index) {
      _joblistIndex = index;
      notifyListeners();
    }

    if (_joblistController.hasClients) {
      _joblistController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _joblistController.dispose();
    super.dispose();
  }
}