enum RANK { CPT, FO, CD, CC }

String rankString(RANK rank) {
  switch (rank) {
    case RANK.CPT: return "CPT"; break;
    case RANK.FO: return "FO"; break;
    case RANK.CD: return "CD"; break;
    case RANK.CC: return "CC / PGC"; break;
    default: return "";
  }
}
