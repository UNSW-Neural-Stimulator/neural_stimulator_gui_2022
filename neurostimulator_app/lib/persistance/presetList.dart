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
                return InkWell(
                  onTap: () {
                    myProvider.setFromPreset(presets[index]);
                  },
                  child: Card(
                    child: ListTile(
                      leading: Tooltip(
                          textStyle: TextStyle(fontSize: 15),
                          message: previewString(presets, index),
                          child: new Text("Preview")),
                      title: Text(presets[index]["preset_name"]),
                      trailing: TextButton(
                        child: Text("Delete", style: TextStyle(color: Colors.red),),
                        onPressed: () {
                          presetProvider.delete_preset(presets[index]);
                          setState(() {
                            
                          });
                        },
                      ),
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
          TextButton(
                child: Text("Cancel", style: TextStyle(color: Colors.red),),
                onPressed: () => Navigator.pop(context),
          )
        ]),
      ),
    ]);
  }
}

String previewString(List<dynamic> presets, int index) {
  return "DC mode: " +
      presets[index]["dc_mode"].toString() +
      "\nCathodic first: " +
      presets[index]["cathodic_first"].toString() +
      "\nPhase one time: " +
      presets[index]["phase_one_time"].toString() +
      "\nPhase two time: " +
      presets[index]["phase_two_time"].toString() +
      "\nInter phase gap: " +
      presets[index]["inter_phase_gap"].toString() +
      "\nInter stim delay:" +
      presets[index]["inter_stim_delay"].toString() +
      "\nPhase 1 current: " +
      presets[index]["dac_phase_one"].toString() +
      "\nPhase 2 current: " +
      "\nFrequency: " +
      presets[index]["frequency"].toString() +
      presets[index]["dac_phase_two"].toString() +
      "\nDC ramp up time: " +
      presets[index]["ramp_up_time"].toString() +
      "\nDC hold time: " +
      presets[index]["dc_hold_time"].toString() +
      "\nDC current target: " +
      presets[index]["dc_curr_target"].toString() +
      "\nDC burst gap: " +
      presets[index]["dc_burst_gap"].toString() +
      "\nDC number of bursts: " +
      presets[index]["dc_burst_num"].toString() +
      "\nMinutes (duration): " +
      presets[index]["end_by_minutes"].toString() +
      "\nSeconds (duration): " +
      presets[index]["end_by_seconds"].toString() +
      "\nNumber of bursts (duration): " +
      presets[index]["end_by_value"].toString() +
      "\nEnd by bursts: " +
      presets[index]["end_by_burst"].toString() +
      "\nEnd by Duration: " +
      presets[index]["end_by_duration"].toString() +
      "\nStimulate Forever: " +
      presets[index]["stim_forever"].toString();
}
