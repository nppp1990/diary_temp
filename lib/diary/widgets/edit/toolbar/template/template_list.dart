import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/template.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_add_dialog.dart';
import 'package:dribbble/diary/widgets/loading.dart';
import 'package:flutter/material.dart';

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  static final _testData = [
    // Template(
    //     name: 'My day',
    //     isBuiltIn: true,
    //     data:
    //     r'[{"insert":"My day"},{"insert":"\n","attributes":{"header":2}},{"insert":"☀️ What was the best thing about today and why? \n\n⚡️ What were the challenges today and how did I overcome them? \n\n💫 What interesting or unusual things happened today? \n\n💙 What was my emotional state during the day and what influenced it?  \n"}]',
    //     desc: 'A simple template to record your day',
    //     backgroundColor: const Color(0xFFF8F8F8)),
    Template(
        name: 'Gratitude',
        isBuiltIn: true,
        data:
            r'[{"insert":"Gratitude"},{"insert":"\n","attributes":{"header":2}},{"insert":"🌈 What are you grateful for today? \n\n🌟 What made you smile today? \n\n🌺 What made you feel loved today? \n\n🌿 What made you feel proud today? \n\n🌼 What made you feel inspired today? \n"}]',
        desc: 'A simple template to record your gratitude',
        backgroundColor: const Color(0xFFFCEDE1)),
    // 1. 今天学到了什么？
    // 2. 你遇到的新朋友
    // 3. 让你惊奇的事情
    Template(
      name: '记录下生活的细节',
      isBuiltIn: true,
      data:
          r'[{"insert":"\n","attributes":{"header":2}},{"insert":"今天学到了什么","attributes":{"color":"#FF909090"}},{"insert":"\n","attributes":{"list":"bullet"}},{"insert":"\n\n"},{"insert":"你遇到的新朋友","attributes":{"color":"#FF909090"}},{"insert":"\n","attributes":{"list":"bullet"}},{"insert":"\n\n"},{"insert":"让你惊奇的事情","attributes":{"color":"#FF909090"}},{"insert":"\n","attributes":{"list":"bullet"}}]',
      desc: '捕捉生活中的故事性瞬间',
      backgroundColor: const Color(0xFFCACFCA),
    ),
    Template(
      name: '记录日常',
      isBuiltIn: true,
      data:
          r'[{"insert":"标题"},{"insert":"\n","attributes":{"header":2}},{"insert":"\n今天发生在我身上最值得讲述的事情是什么？"},{"insert":"\n","attributes":{"list":"bullet"}},{"insert":"用不超过两句话将它记录下来"},{"insert":"\n","attributes":{"list":"bullet"}},{"insert":"\n\n"}]',
      desc: '看似平凡的日常，也有值得记录的美好',
      backgroundColor: const Color(0xFFF8F8F8),
    ),
    Template(
      name: '奥德赛计划',
      isBuiltIn: true,
      data:
          r'[{"insert":"奥德赛计划"},{"insert":"\n","attributes":{"header":2}},{"insert":"\n问自己，“"},{"insert":"如果我继续沿着现在的道路前进，五年后的生活会是什么样子","attributes":{"bold":true}},{"insert":"” 然后详细记录你的思考"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"接着问自己，“"},{"insert":"如果我选择一条完全不同的人生道路，五年后的生活又会是什么样？","attributes":{"bold":true}},{"insert":"” 同样记录下你想象和思考"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"最后问自己，“"},{"insert":"如果我选择了一条完全不同的道路，而且不需要考虑经济压力，也不在乎他人的眼光，五年后的生活是什么样子？","attributes":{"bold":true}},{"insert":"” 再次记录下你的思考"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"\n\n"}]',
      desc: '探索未来的可能性',
      backgroundColor: const Color(0xFFE1F7F8),
    )
  ];

  final List<Template> _items = [];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _removeItem(int index, Template template) {
    _items.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _TemplateListItem(template: template, animation: animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template List'),
        iconTheme: TestConfiguration.toolbarIconStyle,
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // var template = await TemplateAddDialog.show(context);
              // if (template != null) {
              //   await TestSqliteHelper.instance.insertTemplate(template);
              //   Navigator.pop(context, template);
              // }
            },
          ),
        ],
      ),
      body: FutureLoading<List<Template>, List<Template>>(
        futureBuilder: TestSqliteHelper.instance.getAllTemplates,
        convert: (localTemplates) {
          if (localTemplates?.isEmpty ?? true) {
            return _testData;
          }
          return [
            ..._testData,
            ...localTemplates!,
          ];
        },
        contentBuilder: (context, templates) {
          _items.clear();
          _items.addAll(templates);
          return AnimatedList(
            key: _listKey,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            initialItemCount: templates.length,
            itemBuilder: (context, index, animation) {
              return _TemplateListItem(
                template: templates[index],
                animation: animation,
                onDeleted: () => _removeItem(index, templates[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _TemplateListItem extends StatelessWidget {
  final Template template;
  final Animation<double> animation;
  final Function()? onDeleted;

  const _TemplateListItem({required this.template, required this.animation, this.onDeleted});

  _showInfoDialog(BuildContext context, Template template) async {
    var res = await TemplateInfoDialog.show(
      context,
      title: template.name,
      content: template.content,
      desc: template.desc,
      backgroundColor: template.backgroundColor,
      backgroundImage: template.backgroundImage,
    );
    if (context.mounted && res is int && res > 0) {
      Navigator.pop(context, template);
    }
  }

  _onLongPress(BuildContext itemContext) {
    if (template.isBuiltIn) {
      return;
    }
    // show bottom sheet: view、update、delete
    showModalBottomSheet(
      useSafeArea: true,
      context: itemContext,
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.remove_red_eye_outlined),
                  title: const Text('View'),
                  onTap: () async {
                    Navigator.pop(context);
                    _showInfoDialog(itemContext, template);
                  },
                ),
              ),
              const Divider(color: TestColors.greyDivider1, height: 1),
              Material(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Update'),
                  onTap: () {
                    Navigator.pop(context);
                    // var res = await TemplateAddDialog.show(context, template: template);
                    // if (res != null) {
                    //   await TestSqliteHelper.instance.updateTemplate(res);
                    //   Navigator.pop(context, res);
                    // }
                  },
                ),
              ),
              const Divider(color: TestColors.greyDivider1, height: 1),
              Material(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteTemplate(itemContext, template);
                  },
                ),
              ),
              const Divider(color: TestColors.greyDivider1, height: 1),
            ],
          ),
        );
      },
    );
  }

  _deleteTemplate(BuildContext context, Template template) async {
    var res = await DialogUtils.showConfirmDialog(context,
        title: 'Delete template?', content: 'The template will be permanently removed', confirmText: 'Delete');
    if (res is int && res > 0) {
      var res = await TestSqliteHelper.instance.deleteTemplate(template.id!);
      print('delete----????$res');
      if (res > 0 && context.mounted) {
        DialogUtils.showToast(context, 'Template deleted');
        onDeleted?.call();
      }
    } else {
      print('cancel----$res');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('---build item---desc: ${template.desc}, name: ${template.name}');
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding, vertical: 8),
          child: OffsetCard(
            cardHeight: TestConfiguration.templateItemHeight,
            offset: const Offset(0, 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                _showInfoDialog(context, template);
              },
              onLongPress: template.isBuiltIn ? null : () => _onLongPress(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: TestConfiguration.templateItemHeight,
                decoration: BoxDecoration(
                  color: template.backgroundColor,
                  image: template.backgroundImage == null
                      ? null
                      : DecorationImage(
                          image: AssetImage(template.backgroundImage!),
                          fit: BoxFit.cover,
                        ),
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              template.desc ?? '暂无描述',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, template);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.white,
                          foregroundColor: TestColors.black1,
                          side: const BorderSide(color: TestColors.black1, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        ),
                        child: const Text(
                          'Use',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
