require 'spec_helper'

describe "mixin" do
  before do
    class Alpha 
      def action
        return 1
      end
    end
    module TestModule
      def action
        return 2
      end
      def action2
        return 3
      end
    end
    module TestModule2
      def action
        return 4
      end
      def action2
        return 5
      end
    end
  end
  it 'alphaのインスタンスは1を返す' do
    a = Alpha.new
    expect(a.action).to eq(1)
  end
  it 'alphaにTestModuleをExtendしたインスタンスは2を返す' do
    a = Alpha.new
    a.extend(TestModule)
    expect(a.action).to eq(2)
    expect(a.action2).to eq(3)
  end
  it 'alphaにTestModule, TestModule2をExtendしたインスタンスは4を返す' do
    a = Alpha.new
    a.extend(TestModule)
    a.extend(TestModule2)
    expect(a.action).to eq(4)
    expect(a.action2).to eq(5)
  end
  it 'alphaにTestModule2, TestModuleをExtendしたインスタンスは2を返す(extendする順に上書きされる' do
    a = Alpha.new
    a.extend(TestModule2)
    a.extend(TestModule)
    expect(a.action).to eq(2)
    expect(a.action2).to eq(3)
  end
end

