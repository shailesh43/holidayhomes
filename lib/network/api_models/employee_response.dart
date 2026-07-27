class EmployeeResponse {
  List<EmployeeData>? data;

  EmployeeResponse({this.data});

  EmployeeResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <EmployeeData>[];
      json['data'].forEach((v) {
        data!.add(EmployeeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapData = <String, dynamic>{};
    if (data != null) {
      mapData['data'] = data!.map((v) => v.toJson()).toList();
    }
    return mapData;
  }
}

class EmployeeData {
  String? sAPEMPNO;
  String? sAPSHORTNAME;
  String? sAPGENDERDESC;
  String? sAPDOB;
  String? sAPDOJPERM;
  String? sAPORGUNITDESC;
  String? sAPCOSTCENTER;
  String? sAPCOSTCENTERDESC;
  String? sAPCURRPOSITIONDESC;
  String? sAPCURRGRADEDESC;
  String? sAPEMAIL;
  String? sAPDISPNAME;
  String? sAPEMPMGR;
  String? sAPEMPMGREMAILID;
  String? sAPEMPLOYEESTATUSTEXT;
  String? wORKLOCATIONDESCRIPTION;
  String? sAPMOBILENO;
  String? wORKLONGTXT;
  String? hRCLTEXT;
  String? sBUTEXT;
  String? dIVHRID;
  String? dIVHRNAME;
  String? dIVHEADHRID;
  String? dIVHEADHRNAME;
  String? cLUHEADHRID;
  String? cLUHEADHRNAME;
  String? bUSINESSHREMAIL;
  String? hEADHREMAIL;
  String? cLUSTERHREMAIL;
  String? iSMANAGER;
  String? sAPCOMPANYDESC;
  String? sAPCOMPANY;
  String? mANAGER;
  String? sAPCHANGEDON;
  String? sAPPAYROLLAREA;
  String? sAPCURRGRADEDESCHDHOME;

  EmployeeData({
    this.sAPEMPNO,
    this.sAPSHORTNAME,
    this.sAPGENDERDESC,
    this.sAPDOB,
    this.sAPDOJPERM,
    this.sAPORGUNITDESC,
    this.sAPCOSTCENTER,
    this.sAPCOSTCENTERDESC,
    this.sAPCURRPOSITIONDESC,
    this.sAPCURRGRADEDESC,
    this.sAPEMAIL,
    this.sAPDISPNAME,
    this.sAPEMPMGR,
    this.sAPEMPMGREMAILID,
    this.sAPEMPLOYEESTATUSTEXT,
    this.wORKLOCATIONDESCRIPTION,
    this.sAPMOBILENO,
    this.wORKLONGTXT,
    this.hRCLTEXT,
    this.sBUTEXT,
    this.dIVHRID,
    this.dIVHRNAME,
    this.dIVHEADHRID,
    this.dIVHEADHRNAME,
    this.cLUHEADHRID,
    this.cLUHEADHRNAME,
    this.bUSINESSHREMAIL,
    this.hEADHREMAIL,
    this.cLUSTERHREMAIL,
    this.iSMANAGER,
    this.sAPCOMPANYDESC,
    this.sAPCOMPANY,
    this.mANAGER,
    this.sAPCHANGEDON,
    this.sAPPAYROLLAREA,
    this.sAPCURRGRADEDESCHDHOME,
  });

  EmployeeData.fromJson(Map<String, dynamic> json) {
    sAPEMPNO = json['SAP_EMP_NO'];
    sAPSHORTNAME = json['SAP_SHORT_NAME'];
    sAPGENDERDESC = json['SAP_GENDER_DESC'];
    sAPDOB = json['SAP_DOB'];
    sAPDOJPERM = json['SAP_DOJ_PERM'];
    sAPORGUNITDESC = json['SAP_ORG_UNIT_DESC'];
    sAPCOSTCENTER = json['SAP_COST_CENTER'];
    sAPCOSTCENTERDESC = json['SAP_COST_CENTER_DESC'];
    sAPCURRPOSITIONDESC = json['SAP_CUR_POSITION_DESC']; // Note: sometimes APIs misspell this
    sAPCURRGRADEDESC = json['SAP_CURR_GRADE_DESC'];
    sAPEMAIL = json['SAP_EMAIL'];
    sAPDISPNAME = json['SAP_DISP_NAME'];
    sAPEMPMGR = json['SAP_EMP_MGR'];
    sAPEMPMGREMAILID = json['SAP_EMP_MGR_EMAILID'];
    sAPEMPLOYEESTATUSTEXT = json['SAP_EMPLOYEE_STATUS_TEXT'];
    wORKLOCATIONDESCRIPTION = json['WORK_LOCATION_DESCRIPTION'];
    sAPMOBILENO = json['SAP_MOBILE_NO'];
    wORKLONGTXT = json['WORK_LONG_TXT'];
    hRCLTEXT = json['HRCL_TEXT'];
    sBUTEXT = json['SBU_TEXT'];
    dIVHRID = json['DIV_HR_ID'];
    dIVHRNAME = json['DIV_HR_NAME'];
    dIVHEADHRID = json['DIV_HEAD_HR_ID'];
    dIVHEADHRNAME = json['DIV_HEAD_HR_NAME'];
    cLUHEADHRID = json['CLU_HEAD_HR_ID'];
    cLUHEADHRNAME = json['CLU_HEAD_HR_NAME'];
    bUSINESSHREMAIL = json['BUSINESSHR_EMAIL'];
    hEADHREMAIL = json['HEAD_HR_EMAIL'];
    cLUSTERHREMAIL = json['CLUSTER_HR_EMAIL'];
    iSMANAGER = json['ISMANAGER'];
    sAPCOMPANYDESC = json['SAP_COMPANY_DESC'];
    sAPCOMPANY = json['SAP_COMPANY'];
    mANAGER = json['MANAGER'];
    sAPCHANGEDON = json['SAP_CHANGED_ON'];
    sAPPAYROLLAREA = json['SAP_PAYROLL_AREA'];
    sAPCURRGRADEDESCHDHOME = json['SAP_CURR_GRADE_DESC_HDHOME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SAP_EMP_NO'] = sAPEMPNO;
    data['SAP_SHORT_NAME'] = sAPSHORTNAME;
    data['SAP_GENDER_DESC'] = sAPGENDERDESC;
    data['SAP_DOB'] = sAPDOB;
    data['SAP_DOJ_PERM'] = sAPDOJPERM;
    data['SAP_ORG_UNIT_DESC'] = sAPORGUNITDESC;
    data['SAP_COST_CENTER'] = sAPCOSTCENTER;
    data['SAP_COST_CENTER_DESC'] = sAPCOSTCENTERDESC;
    data['SAP_CUR_POSITION_DESC'] = sAPCURRPOSITIONDESC;
    data['SAP_CURR_GRADE_DESC'] = sAPCURRGRADEDESC;
    data['SAP_EMAIL'] = sAPEMAIL;
    data['SAP_DISP_NAME'] = sAPDISPNAME;
    data['SAP_EMP_MGR'] = sAPEMPMGR;
    data['SAP_EMP_MGR_EMAILID'] = sAPEMPMGREMAILID;
    data['SAP_EMPLOYEE_STATUS_TEXT'] = sAPEMPLOYEESTATUSTEXT;
    data['WORK_LOCATION_DESCRIPTION'] = wORKLOCATIONDESCRIPTION;
    data['SAP_MOBILE_NO'] = sAPMOBILENO;
    data['WORK_LONG_TXT'] = wORKLONGTXT;
    data['HRCL_TEXT'] = hRCLTEXT;
    data['SBU_TEXT'] = sBUTEXT;
    data['DIV_HR_ID'] = dIVHRID;
    data['DIV_HR_NAME'] = dIVHRNAME;
    data['DIV_HEAD_HR_ID'] = dIVHEADHRID;
    data['DIV_HEAD_HR_NAME'] = dIVHEADHRNAME;
    data['CLU_HEAD_HR_ID'] = cLUHEADHRID;
    data['CLU_HEAD_HR_NAME'] = cLUHEADHRNAME;
    data['BUSINESSHR_EMAIL'] = bUSINESSHREMAIL;
    data['HEAD_HR_EMAIL'] = hEADHREMAIL;
    data['CLUSTER_HR_EMAIL'] = cLUSTERHREMAIL;
    data['ISMANAGER'] = iSMANAGER;
    data['SAP_COMPANY_DESC'] = sAPCOMPANYDESC;
    data['SAP_COMPANY'] = sAPCOMPANY;
    data['MANAGER'] = mANAGER;
    data['SAP_CHANGED_ON'] = sAPCHANGEDON;
    data['SAP_PAYROLL_AREA'] = sAPPAYROLLAREA;
    data['SAP_CURR_GRADE_DESC_HDHOME'] = sAPCURRGRADEDESCHDHOME;
    return data;
  }
}