import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_provider.dart';
import '../preset_provider.dart';

class presetContainer extends StatefulWidget {
  @override
  State<presetContainer> createState() => _presetContainer();
}

class _presetContainer extends State<presetContainer> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final Presets presetProvider = Provider.of<Presets>(context);
    final Data myProvider = Provider.of<Data>(context, listen: false);

    List<dynamic> presets = presetProvider.load_presets();
    return Wrap(children: [
      Container(
        height: 400.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: Column(children: [
          Container(
            height: 300,
            width: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: presets.length,
              itemBuilder: (BuildContext context, int index) {
                print(index);
                return InkWell(
                  onTap: () {},
                  child: Card(
                    child: ListTile(
                      title: Text(presets[index]["preset_name"]),
                      trailing:
                          // I know this is bad
                          Tooltip(
                              textStyle: TextStyle(fontSize: 15),
                              message: "dc_mode:" +
                                  presets[index]["dc_mode"].toString() +
                                  "\ncathodic_first: " +
                                  presets[index]["cathodic_first"].toString() +
                                  "\nphase_one_time: " +
                                  presets[index]["phase_one_time"].toString() +
                                  "\nphase_two_time: " +
                                  presets[index]["phase_two_time"].toString() +
                                  "\ninter_phase_gap: " +
                                  presets[index]["inter_phase_gap"].toString() +
                                  "\ninter_stim_delay:" +
                                  presets[index]["inter_stim_delay"]
                                      .toString() +
                                  "\ndac_phase_one: " +
                                  presets[index]["dac_phase_one"].toString() +
                                  "\ndac_phase_two: " +
                                  presets[index]["dac_phase_two"].toString() +
                                  "\nramp_up_time: " +
                                  presets[index]["ramp_up_time"].toString() +
                                  "\ndc_hold_time: " +
                                  presets[index]["dc_hold_time"].toString() +
                                  "\ndc_curr_target: " +
                                  presets[index]["dc_curr_target"].toString() +
                                  "\ndc_burst_gap: " +
                                  presets[index]["dc_burst_gap"].toString() +
                                  "\ndc_burst_num: " +
                                  presets[index]["dc_burst_num"].toString() +
                                  "\nend_by_minutes: " +
                                  presets[index]["end_by_minutes"].toString() +
                                  "\nend_by_seconds: " +
                                  presets[index]["end_by_seconds"].toString() +
                                  "\nend_by_value:" +
                                  presets[index]["end_by_value"].toString(),
                              child: new Text("Preview")),
                    ),
                  ),
                );
              },
            ),
          ),
          TextField(
            onSubmitted: (value) {
              presetProvider.save_presets(myProvider.generatePresetMap(value));
              controller.clear();
              setState(() {});
            },
            controller: controller,
            decoration: InputDecoration(
                hintText: "Name this current session as a new preset."),
          ),
          SizedBox(
            height: 10,
          ),
        ]),
      ),
    ]);
  }
}
