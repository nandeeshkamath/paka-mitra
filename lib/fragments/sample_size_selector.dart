import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class SampleSizeSelector extends StatefulWidget {
  const SampleSizeSelector({
    super.key,
    required this.samples,
    required this.defaultSample,
    required this.onChanged,
    this.toolTip,
  });
  final String? toolTip;
  final Set<int> samples;
  final int defaultSample;
  final Function(int changed) onChanged;

  @override
  State<SampleSizeSelector> createState() => _SampleSizeSelectorState();
}

class _SampleSizeSelectorState extends State<SampleSizeSelector> {
  // _SampleSizeSelectorState({
  //   required this.selectedSample,
  // });
  int selectedSample = 50;

  @override
  void initState() {
    super.initState();

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
                  widget.onChanged(sample);
                });
              },
              child: Container(
                height: 40,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: tertiary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: selectedSample == sample ? secondary : null,
                ),
                child: Center(
                  child: Text(
                    sample.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedSample == sample
                          ? primary
                          : primary.withOpacity(0.8),
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
