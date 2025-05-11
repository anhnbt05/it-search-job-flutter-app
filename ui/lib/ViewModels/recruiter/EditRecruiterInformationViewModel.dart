import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'ProfileViewModel.dart';

class EditRecruiterInformationViewMode extends ChangeNotifier {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _positionController;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get positionController => _positionController;

  EditRecruiterInformationViewMode(BuildContext context) {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context);
    _fullNameController = TextEditingController(text: profileViewModel.recruiterInfo!.FullName);
    _phoneNumberController = TextEditingController(text: profileViewModel.recruiterInfo!.PhoneNumber);
    _positionController = TextEditingController(text: profileViewModel.recruiterInfo!.Position);
  }
}