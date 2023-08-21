program credits.aleo{
    record credits {
        owner : address,
        microcredits : u64,
    }

    mapping account : address => u64;

    transition mint(public receiver : address, public amount : u64) -> credits{
        assert_eq(receiver,self.caller);
        let check : bool = (amount < 100000000000000u64);
        assert_eq(check, true);
        let new_record : credits = credits {
            owner : receiver,
            microcredits : amount,
        };
        return new_record;
    }

    transition transfer_public (public receiver : address, public amount : u64){
        return then finalize(self.caller, receiver, amount);
    }
    finalize transfer_public (public sender : address, public receiver : address, public amount : u64){
        let r3 : u64 = account.get_or_use(sender,0u64);
        let diff : u64 = r3 - amount;
        account.set(sender,diff);
        let r5 : u64 = account.get_or_use(receiver, 0u64);
        let r6 : u64 = r5 + amount;
        account.set(receiver, r6);
    }

    transition transfer_private (private r0 : credits, private receiver : address, private amount : u64)-> (credits,credits){
        let r3 : u64 = r0.microcredits - amount;
        let new_record : credits = credits {
            owner : receiver,
            microcredits : amount,
        };
        let new_record2 : credits = credits {
            owner : r0.owner,
            microcredits : r3,
        };
        return (new_record, new_record2);
    }

    transition transfer_private_to_public (private r0 : credits, public receiver : address, public amount : u64)-> credits{
        let r3 : u64 = r0.microcredits - amount;
        let new_record : credits = credits {
            owner : receiver,
            microcredits : amount,
        };
        return new_record then finalize(receiver, amount);
    }
    finalize transfer_private_to_public(r0: address, r1 : u64){
        let r2 : u64 = account.get_or_use(r0,0u64);
        let r3 : u64 = r1 + r2;
        account.set(r0,r3);
    }

    transition transfer_public_to_private (public receiver : address, public amount : u64)-> credits{
        let new_record : credits = credits {
            owner : receiver,
            microcredits : amount,
        };
        return new_record then finalize(self.caller, amount);
    }
    finalize transfer_public_to_private(r0: address, r1 : u64){
        let r2 : u64 = account.get_or_use(r0,0u64);
        let r3 : u64 = r2 - r1;
        account.set(r0,r3);
    }

    transition join(r0 : credits, r1 : credits) -> credits{
        let r2 : u64 = r0.microcredits + r1.microcredits;
        let joined_record : credits = credits{
            owner: r0.owner,
            microcredits : r2,
        };
        return joined_record;
    }

    transition split (r0 : credits, private r1 : u64) -> (credits,credits){
        let r2 : u64 = r0.microcredits - r1;
        let new_record : credits = credits {
            owner : r0.owner,
            microcredits : r1,
        };
        let new_record2 : credits = credits {
            owner : r0.owner,
            microcredits : r2,
        };
        return(new_record,new_record2);
    }

    transition fee (r0 : credits, public r1 : u64, public r2 : field) -> credits{
        assert_neq(r1, 0u64);
        let r3 : u64 = r0.microcredits - r1;
        let new_record : credits = credits{
            owner : r0.owner,
            microcredits : r3,
        };
        return new_record;
    }
}