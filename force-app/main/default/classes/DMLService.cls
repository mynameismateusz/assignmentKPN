public with sharing class DMLService {

    public class DMLResult {
        private final SObject record;
        private final List<Database.Error> errors;

        public SObject getRecord() { return record; }
        public List<Database.Error> getErrors() { return errors; }

        public DMLResult(SObject record, List<Database.Error> errors)
        {
            this.record = record;
            this.errors = errors;
        }

        public DMLResult(SObject record, Database.UpsertResult result) {
            this(record, result.getErrors());
        }
    }

    /**
     * Upsert SObject records. Returned results are ordered in the same way as the given records list.
     * @param {List<SObject>} records: SObjects records to insert
     * @param {Boolean} allOrNone: False to allow for partial upsert success
     * @return {List<DMLResult>} Upserted record + any potential errors
     */
    public static List<DMLResult> upsertRecords(List<SObject> records, Boolean allOrNone) {
        List<Database.UpsertResult> res = Database.upsert(records, allOrNone);
        List<DMLResult> results = new List<DMLResult>();
        for (Integer i = 0; i < res.size(); i++) {
            results.add(new DMLResult(records[i], res[i]));
        }
        return results;
    }
}
