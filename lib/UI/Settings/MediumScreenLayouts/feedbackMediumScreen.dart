import 'package:flutter/material.dart';

class feedbackMediumScreen extends StatefulWidget {
  const feedbackMediumScreen({super.key});

  @override
  State<feedbackMediumScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<feedbackMediumScreen> {
  bool isIssue = true;
  String selectedItem = "Crashes";

  final List<String> issueItems = [
    "Crashes",
    "Page not loading",
    "App not responding",
    "Function disable",
    "Multiple ads",
    "Premium not working",
    "Don't know how to use",
    "Others",
  ];

  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface), onPressed: () {
          Navigator.pop(context);
        },),
        title: Text("Feedback", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerBox(),
            const SizedBox(height: 15),
            _tabs(),
            const SizedBox(height: 20),
            _descriptionField(),
            const SizedBox(height: 15),
            const Text("Select Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _itemSelector(),
            const Spacer(),
            _submitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _headerBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              "Report bugs every time you encounter problems to help us solve them faster.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Icon(Icons.close, size: 20)
        ],
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        _tabButton("Issues", isIssue, () {
          setState(() => isIssue = true);
        }),
        const SizedBox(width: 10),
        _tabButton("Suggestions", !isIssue, () {
          setState(() => isIssue = false);
        }),
      ],
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 5,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: isIssue
            ? "Describe the issue you’ve encountered here.\n1. On what page have you encountered the issue?\n2. After what action did the issue appear?\n3. Additional information to fix the issue."
            : "Tell us how we can improve our app?",
        hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _itemSelector() {
    if (!isIssue) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: issueItems.map((item) {
        bool isSelected = selectedItem == item;
        return GestureDetector(
          onTap: () => setState(() => selectedItem = item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        debugPrint("Mode: ${isIssue ? 'Issue' : 'Suggestion'}");
        debugPrint("Category: $selectedItem");
        debugPrint("Description: ${descriptionController.text}");
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          "Submit",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
