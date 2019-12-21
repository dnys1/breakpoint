import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformTabScaffold extends StatelessWidget {
  final List<IconData> materialTabIcons;
  final List<IconData> cupertinoTabIcons;
  final List<String> tabLabels;
  final List<Widget> tabs;

  PlatformTabScaffold({
    Key key,
    @required this.tabLabels,
    @required this.materialTabIcons,
    @required this.cupertinoTabIcons,
    @required this.tabs,
  })  : assert(tabs.length == cupertinoTabIcons.length),
        assert(tabs.length == materialTabIcons.length),
        assert(tabs.length == tabLabels.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            for (int i = 0; i < tabs.length; i++)
              BottomNavigationBarItem(
                icon: Icon(cupertinoTabIcons[i]),
                title: Text(tabLabels[i]),
              ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          assert(index >= 0 && index < tabs.length);
          return CupertinoTabView(
            builder: (BuildContext context) => tabs[index],
            defaultTitle: tabLabels[index],
          );
        },);
  }
}
