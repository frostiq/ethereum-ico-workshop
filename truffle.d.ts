import { MyIcoToken } from './types/'

declare global {
  function contract(name: string, test: ContractTest): void;
  var artifacts: Artifacts;
  var assert: Chai.AssertStatic;
}

declare type ContractTest = (accounts: string[]) => void;

interface Artifacts {
  require(name: "MyIcoToken"): MyIcoToken;
}
