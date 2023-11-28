import 'package:flutter/material.dart';

class SampleSizeSelector extends StatefulWidget {
  const SampleSizeSelector({
    Key? key,
    required this.samples,
    required this.defaultSample,
    this.toolTip,
  }) : super(key: key);
  final String? toolTip;
  final Set<int> samples;
  final int defaultSample;

  @override
  State<SampleSizeSelector> createState() => _SampleSizeSelectorState();
}

class _SampleSizeSelectorState extends State<SampleSizeSelector> {
  // _SampleSizeSelectorState({
  //   required this.selectedSample,
  // });
  late int selectedSample;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      selectedSample = widget.defaultSample;
    });
  }

  List<Widget> getSamplesButtons() {
    List<Widget> sampleButtons = widget.samples
        .map(
          (sample) => Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedSample = sample;
                });
              },
              child: Container(
                height: 40,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: selectedSample == sample ? Colors.blue : null,
                ),
                child: Center(
                  child: Text(
                    sample.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedSample == sample
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
    return sampleButtons;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: widget.toolTip ?? '',
            child: const Icon(
              Icons.people_outline_sharp,
            ),
          ),
          ...getSamplesButtons(),
        ],
      ),
    );
  }
}
