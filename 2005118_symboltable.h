#include<bits/stdc++.h>
using namespace std;

class SymbolInfo{
private:
    string name;
    string type;
    
public:
    int startLineNo,endLineNo,arrSize;
    vector<SymbolInfo*>parameter_list,parseList;
    bool declared,function,defined,child;
    string typeSpecifier;
    SymbolInfo *next;
    SymbolInfo(string name,string type){
        this->name=name;
        this->type=type;
        declared=false;
        function=false;
        defined=false;
        arrSize=-1;
        next=NULL;

    }
    //copy-constructor;
    SymbolInfo(SymbolInfo &symbolInfo){
        this->name=symbolInfo.name;
        this->type=symbolInfo.type;
        this->next=symbolInfo.next;
        this->startLineNo=symbolInfo.startLineNo;
        this->endLineNo=symbolInfo.endLineNo;
        this->parameter_list=symbolInfo.parameter_list;
        this->declared=symbolInfo.declared;
        this->function=symbolInfo.function;
        this->defined=symbolInfo.defined;
        this->typeSpecifier=symbolInfo.typeSpecifier;
        this->child=symbolInfo.child;
    }
    SymbolInfo(SymbolInfo *symbolInfo){
        this->name=symbolInfo->name;
        this->type=symbolInfo->type;
        this->next=symbolInfo->next;
        this->startLineNo=symbolInfo->startLineNo;
        this->endLineNo=symbolInfo->endLineNo;
        this->parameter_list=symbolInfo->parameter_list;
        this->declared=symbolInfo->declared;
        this->function=symbolInfo->function;
        this->defined=symbolInfo->defined;
        this->typeSpecifier=symbolInfo->typeSpecifier;
    }
    void setName(string name){
        this->name=name;
    }
    void setType(string type){
        this->type=type;
    }
    void setNext(SymbolInfo *next){
        this->next=next;
    }
    string getName(){
        return this->name;
    }
    string getType(){
        return this->type;
    }
    SymbolInfo *getNext(){
        return this->next;
    }
    void addParseList(SymbolInfo *symbolInfo){
        this->parseList.push_back(symbolInfo);
    }
    void parse(int space,ofstream &outputParse){
        for(int i=0;i<space;i++)outputParse<<" ";
        outputParse<<type<<" : "<<name<<" <Line: ";
        if(child)outputParse<<startLineNo<<" >"<<endl;
        else outputParse<<startLineNo<<"-"<<endLineNo<<" >"<<endl;
        for(SymbolInfo *s:parseList){
            s->parse(space++,outputParse);
        }
    }
};

class ScopeTable{
private:
     SymbolInfo **table;
     ScopeTable *parentScope;
     string id;
     int total_buckets;
     ofstream logOut;



public:
    int lvl;

    int sdbm_hash(string name)
    {
        unsigned long long hash = 0;


        for(char c: name)
            hash = (unsigned long long)c + (hash << 6) + (hash << 16) - hash;


        int x=hash%total_buckets;
        return x;

    }

    ScopeTable(int n,ScopeTable *parentScope){
        this->total_buckets=n;
        this->parentScope=parentScope;
        table=new SymbolInfo*[n];
        for(int i=0;i<n;i++){
            table[i]=NULL;
        }
        if(parentScope==NULL){
            id="1";
        }
        else{
            id=parentScope->id;
            id.append(".");
            id.append(to_string(parentScope->lvl));
        }
    }
    ~ScopeTable(){
        for(int i=0;i<total_buckets;i++){
            if(table[i]!=NULL){
                SymbolInfo *s=table[i];
                while (s!=NULL)
                {
                    SymbolInfo *temp=s;
                    s=s->next;
                    delete temp;
                }

            }
        }
        delete[] table;
        //cout<<"\tScopeTable# "<<id<<" deleted"<<endl;

    }
    bool insertSymbol(SymbolInfo *symbolInfo){
        string name=symbolInfo->getName();
        int x=sdbm_hash(name);
        if(table[x]!=NULL)
        {
            if(table[x]->getName()==name){
                //logOut<<"\t"<<table[x]->getName()<<" already exists in the current ScopeTable"<<endl;
                return false;
            }
            else {
                SymbolInfo *temp=table[x],*prev=NULL;
                int cnt=1;
                while (temp!=NULL)
                {
                    if(temp->getName()==name){
                        //logOut<<"\t"<<temp->getName()<<" already exists in the current ScopeTable"<<endl;
                        return false;
                    }
                    cnt++;
                    prev=temp;
                    temp=temp->next;
                }
                if(prev==NULL){
                    table[x]=symbolInfo;
                }
                else{
                    prev->setNext(symbolInfo);
                }
                //cout<<"\tInserted  at position <"<<x+1<<", "<<cnt<<"> of ScopeTable# "<<id<<endl;
                return true;
            }
        }
        else{
            table[x]=symbolInfo;
            //cout<<"\tInserted  at position <"<<x+1<<", "<<1<<"> of ScopeTable# "<<id<<endl;
            return true;
        }
    }
    bool insert(string name,string type,ofstream &logOut){
        int x=sdbm_hash(name);
        if(table[x]!=NULL)
        {
            if(table[x]->getName()==name){
                logOut<<"\t"<<table[x]->getName()<<" already exists in the current ScopeTable"<<endl;
                return false;
            }
            else {
                SymbolInfo *temp=table[x],*prev=NULL;
                int cnt=1;
                while (temp!=NULL)
                {
                    if(temp->getName()==name){
                        logOut<<"\t"<<temp->getName()<<" already exists in the current ScopeTable"<<endl;
                        return false;
                    }
                    cnt++;
                    prev=temp;
                    temp=temp->next;
                }
                if(prev==NULL){
                    table[x]=new SymbolInfo(name,type);
                }
                else{
                    prev->setNext(new SymbolInfo(name,type));
                }
                //cout<<"\tInserted  at position <"<<x+1<<", "<<cnt<<"> of ScopeTable# "<<id<<endl;
                return true;
            }
        }
        else{
            table[x]=new SymbolInfo(name,type);
            //cout<<"\tInserted  at position <"<<x+1<<", "<<1<<"> of ScopeTable# "<<id<<endl;
            return true;
        }
    }
    SymbolInfo *lookup(string name){
        int x=sdbm_hash(name);
        if(table[x]==NULL){
            return NULL;
        }
        SymbolInfo *temp=table[x];
        int cnt=1;
        while(temp!=NULL){
            if(temp->getName()==name){
                //cout<<"\t'"<<temp->getName()<<"' found at position <"<<x+1<<", "<<cnt<<"> of ScopeTable# "<<id<<endl;
                return temp;
            }
            temp=temp->next;
            cnt++;
        }
        return NULL;
    }
    bool Delete(string name){
        int x=sdbm_hash(name);
        if(table[x]==NULL){
            //cout<<"\tNot found in the current ScopeTable# "<<id<<endl;
            return false;
        }
        SymbolInfo *temp=table[x], *prev=NULL;
        int cnt=1;
        while(temp!=NULL){
            if(temp->getName()==name){
                if(prev!=NULL){
                    prev->next=temp->next;
                }
                else{
                    table[x]=temp->next;
                }
                //cout<<"\tDeleted '"<<temp->getName()<<"' from position <"<<x+1<<", "<<cnt<<"> of ScopeTable# "<<id<<endl;
                delete temp;
                return true;
            }
            prev=temp;
            temp=temp->next;
            cnt++;
        }
        //cout<<"\tNot found in the current ScopeTable# "<<id<<endl;
        return false;
    }
    void print(ofstream &logOut){
        logOut<<"\tScopeTable# "<<id<<endl;
        for(int i=0;i<total_buckets;i++){
            if(table[i]!=NULL){
                logOut<<"\t"<<i+1<<" --> ";
                SymbolInfo *temp=table[i];
                logOut<<"("<<temp->getName()<<","<<temp->getType()<<")";
                temp=temp->next;
                 while(temp!=NULL){
                    logOut<<" --> ("<<temp->getName()<<","<<temp->getType()<<")";
                    temp=temp->next;
                }
                logOut<<endl;
            }
            else {
                logOut<<"\t"<<i+1<<endl;
            }
        }
    }
    void setParentTable(ScopeTable *parent){
        this->parentScope=parent;
    }
    ScopeTable * getParentScope(){
        return this->parentScope;
    }
    string getId(){
        return this->id;
    }

};
class SymbolTable{
private:
    ScopeTable *currentScopeTable;
    int total_buckets;
    int cnt;
public:
    SymbolTable(int n){
        this->total_buckets=n;
        currentScopeTable=NULL;
        cnt=1;
        this->enterScope();
    }
    ~SymbolTable(){
        while(currentScopeTable!=NULL&&currentScopeTable->getId()!="1"){
            this->exitScope();
        }
        delete currentScopeTable;
    }
    void enterScope(){
        ScopeTable *newScope=new ScopeTable(total_buckets,currentScopeTable);
        currentScopeTable=newScope;
        currentScopeTable->lvl=1;
        //cout<<"\tScopeTable# "<<currentScopeTable->getId()<<" created\n";
    }
    void exitScope(){
        if(currentScopeTable==NULL){
            //cout<<"\tNo ScopeTable"<<endl;
            return;
        }
        ScopeTable *temp=currentScopeTable;
        if(temp->getParentScope()==NULL){
            //cout<<"\tScopeTable# 1 cannot be deleted"<<endl;
            return;
        }
        //cout<<"\tScopeTable# "<<currentScopeTable->getId()<<" deleted"<<endl;
        currentScopeTable=temp->getParentScope();
        currentScopeTable->lvl++;
        delete temp;
    }
    bool insert(string name,string type,ofstream &logOut){
        return currentScopeTable->insert(name,type,logOut);
    }
    bool insertSymbol(SymbolInfo *symbolInfo){
        return currentScopeTable->insertSymbol(symbolInfo);
    }
    bool remove(string name){
        return currentScopeTable->Delete(name);
    }
    SymbolInfo *lookupCurrent(string name){
        if(currentScopeTable==NULL){
            return NULL;
        }
        return currentScopeTable->lookup(name);
    }
    SymbolInfo *lookup(string name){
        if(currentScopeTable==NULL){
            return NULL;
        }
        else{
            ScopeTable *temp=currentScopeTable;
            SymbolInfo *x;
            while(temp->getParentScope()!=NULL){
                x=temp->lookup(name);
                if(x!=NULL){
                    return x;
                }
                temp=temp->getParentScope();
            }
            if(temp==NULL){
                return NULL;
            }
            return temp->lookup(name);
        }
    }
    void printCurrentTable(ofstream &logOut){

        currentScopeTable->print(logOut);
    }
    void printAllScopeTable(ofstream &logOut){
        ScopeTable *temp=currentScopeTable;
        if(temp==NULL){
            return;
        }
        while(temp->getParentScope()!=NULL){
            temp->print(logOut);
            temp=temp->getParentScope();
        }
        if(temp!=NULL){
            temp->print(logOut);
        }
    }
    void exit(){
        while(currentScopeTable!=NULL&&currentScopeTable->getId()!="1"){
            this->exitScope();
        }
        //cout<<"\tScopeTable# 1 deleted\n";
        delete currentScopeTable;
    }
};





