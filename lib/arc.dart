library arc;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseStore {
  Map<String, dynamic> viewmodels = {};

  void notify<T extends BaseViewModel>(List<String> names) {
    names.forEach((name) {
      T model = viewmodels[name];
      if (model == null) {
        throw "NO viewmodel found with name=$name";
      }
      model.notifyListeners();
    });
  }

  void notifyAll<T extends BaseViewModel>() => notify(viewmodels.keys.toList());
}

enum EState {
  Idling,
  Loading,
  Error,
}

class BaseViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, EState> state = {
    "main": EState.Idling,
  };

  setState(String key, EState newState) {
    state[key] = newState;
    notifyListeners();
  }
}

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  T get viewmodel => null;

  // Scaffold settings
  Color get backgroundColor => Colors.white;
  AppBar appBar(BuildContext context) => null;

  // Column & Scroll controller
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start;
  final bool center = false;
  final bool stacked = false;

  Widget wrapper(
    BuildContext context,
    T model,
    List<Widget> Function(BuildContext context, T model) widgets,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: model.scaffoldKey,
        backgroundColor:
            this.backgroundColor ?? Theme.of(context).backgroundColor,
        appBar: this.appBar(context),
        body: Container(
          height: double.infinity,
          child: SafeArea(
            child: this.center
                ? Center(
                    child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: this.mainAxisAlignment,
                      crossAxisAlignment: this.crossAxisAlignment,
                      children: widgets(context, model),
                    ),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: this.mainAxisAlignment,
                      crossAxisAlignment: this.crossAxisAlignment,
                      children: widgets(context, model),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> builder(BuildContext context, T model) {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewmodel,
      builder: (BuildContext context, Widget widget) =>
          wrapper(context, viewmodel, builder),
    );
  }
}
