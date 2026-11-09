import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

final names = [ '💭 いつか叶えたい', '🚀 叶える途中',  '✨ 叶えた！'];
final labels = ['いつか叶えたい',  '叶える途中',  '叶えた！'];
final colors = [Color(0xFFEFE8FB),  Color(0xFFFFF0D8), Color(0xFFE4F4EA),];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();

  void add() {
    widget.vm.add(input.text);
    input.clear();
  }

  Future<void> edit(Task t) async {
    var text = t.title;
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('タスクを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, text),
            child: Text('保存'),
          ),
        ],
      ),
    );
  if (result != null) widget.vm.rename(t, result);
  }

    // 夢の達成状況を表示する
  Widget dreamProgress() {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) {
        // 「叶えた！」にある夢の数を数える
        final achieved = widget.vm.tasks
            .where((t) => t.status == 2)
            .length;

        // 100個を目標に進捗率を計算
        final progress = (achieved / 100).clamp(0.0, 1.0);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ 叶えた夢：$achieved / 100',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  color: const Color(0xFF9A7ACB),
                  backgroundColor: const Color(0xFFEDE7F5),
                ),
                const SizedBox(height: 8),
                Text(
                  '達成率：${(progress * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget taskCard(Task t) {
    final s = t.status;
    final buttons = Wrap(spacing: 4, children: [
      if (s > 0)
        TextButton(
          onPressed: () => widget.vm.move(t, s - 1),
          child: Text('← ${labels[s - 1]}へ'),
        ),
      if (s < 2)
        FilledButton(
          onPressed: () => widget.vm.move(t, s + 1),
            child: Text('${labels[s + 1]}へ →'),
          ),
          ]);
    return Card(child: ListTile(
      title: Text(t.title),
      subtitle: buttons,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => edit(t),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () => widget.vm.remove(t),
        ),
      ]),
    ));
  }

  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];
    return SizedBox(
      width: 300,
      child: Card(
        color: colors[s],
        child: Column(children: [
          ListTile(
            title: Text(names[s]),
            trailing: Text('${cards.length}件'),
          ),
          Expanded(child: ListView(children: cards)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: 'newやりたいこと',
        hintText: '例：福岡に行って美味しいものを食べる',
        border: OutlineInputBorder(),
      ),
    );
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('やりたいことを追加'),
      ),
    );
    final entry = Card(child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(children: [
        field,
        Align(alignment: Alignment.centerRight, child: button),
      ]),
    ));
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [for (int s = 0; s < 3; s++) lane(s)],
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFFFCFAFF),
      appBar: AppBar(
        title: Text('🌏 MY BUCKET LIST'),
        backgroundColor: Color(0xFFE9E4FA),
      ),
      body: Column(
        children: [
          dreamProgress(),
          entry,
          Expanded(child: board),
        ],
    ),
    );
    
    
  }
}