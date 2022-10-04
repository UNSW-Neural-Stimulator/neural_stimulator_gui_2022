
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';


class Presets extends ChangeNotifier {
  
	LocalStorage storage = LocalStorage('nstimPresets.json');
	
	List<dynamic> presets = [];


	void save_presets (Map<String, dynamic> presetMap) {
		if (storage.getItem("presets") != null) {
			presets = storage.getItem("presets");
		}
		presets.add(presetMap);
		storage.setItem('presets', presets);

		
	} 

	List<dynamic> load_presets () {
		if (storage.getItem("presets") != null) {
			presets = storage.getItem("presets");
			return presets;
		}
		else {
			return [];
		}

		
	}

  


}