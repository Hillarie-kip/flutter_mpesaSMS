import 'dart:convert';

class MpesaSMSModel {
  int ?_id;
  late String _transID;
  late String _mpesaAmount;
  late String _mpesaPhoneNumber;
  late String _mpesaUserName;
  late String _mpesaTransDate;
  late int _statusID;
  late int _addedBy;


  late String _dateTime;

  MpesaSMSModel(
  this. _transID,
  this._mpesaAmount,
  this._mpesaPhoneNumber,
  this._mpesaUserName,
  this._mpesaTransDate,
  this._addedBy,
  this._statusID,
   this._dateTime);

  MpesaSMSModel.withId(
  this._id,
  this. _transID,
  this._mpesaAmount,
  this._mpesaPhoneNumber,
  this._mpesaUserName,
  this._mpesaTransDate,
  this._addedBy,
  this._statusID,
  this._dateTime);

  int? get id => _id;
  String get transID => _transID;
  String get mpesaAmount => _mpesaAmount;
  String get mpesaPhoneNumber => _mpesaPhoneNumber;
  String get mpesaUserName => _mpesaUserName;
  String get mpesaTransDate => _mpesaTransDate;
  int get addedBy => _addedBy;
  int get statusID => _statusID;
  String get dateTime => _dateTime;

  set transID(String transID) {
    _transID = transID;
  }
  set mpesaAmount(String mpesaAmount) {
    _mpesaAmount = mpesaAmount;
  }
  set mpesaPhoneNumber(String mpesaPhoneNumber) {
    _mpesaPhoneNumber = mpesaPhoneNumber;
  }
  set mpesaUserName(String mpesaUserName) {
    _mpesaUserName = mpesaUserName;
  }
  set mpesaTransDate(String mpesaTransDate) {
    _mpesaTransDate = mpesaTransDate;
  }

  set addedBy(int addedBy) {
    if (addedBy >= 1) {
      _addedBy = addedBy;
    }
  }

  set dateTime(String newDate) {
    _dateTime = newDate;
  }

  // Convert a  object into a Map object
  Map<String, dynamic> toMap() {
    // ignore: prefer_collection_literals
    var map = Map<String, dynamic>();
    if (id != null) {
      map['ID'] = _id;
    }
    map['TransID'] = _transID;
    map['MpesaAmount'] = _mpesaAmount;
    map['MpesaPhoneNumber'] = _mpesaPhoneNumber;
    map['MpesaUserName'] = _mpesaUserName;
    map['MpesaTransDate'] = _mpesaTransDate;
    map['AddedBy'] = _addedBy;
    map['StatusID'] = _statusID;
    map['DateTime'] = _dateTime;

    return map;
  }

  // Extract a  object from a Map object
  MpesaSMSModel.fromMapObject(Map<String, dynamic> map) {
    _id = map['ID'];
    _transID  =map['TransID'];
    _mpesaAmount =map['MpesaAmount'];
    _mpesaPhoneNumber =map['MpesaPhoneNumber'];
    _mpesaUserName =map['MpesaUserName'];
    _mpesaTransDate =map['MpesaTransDate'];
    _addedBy =map['AddedBy'];
    _statusID =map['StatusID'];
    _dateTime =map['DateTime'];

  }

  Map<String, dynamic> toJson() {
    return {
      'TransID': _transID,
      'MpesaAmount': _mpesaAmount,
      'MpesaPhoneNumber': _mpesaPhoneNumber,
    };
  }





}




