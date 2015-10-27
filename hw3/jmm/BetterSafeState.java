import java.util.concurrent.locks.ReentrantLock;

class BetterSafeState implements State {
	private byte[] value;
	private byte maxval;

	private final ReentrantLock l = new ReentrantLock();

	BetterSafeState(byte[] v) { value = v; maxval = 127; }

	BetterSafeState(byte[] v, byte m) { value = v; maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j) {
		l.lock();
		if (value[i] <= 0 || value[j] >= maxval) {
			l.unlock();
			return false;
		}
		value[i]--;
		value[j]++;
		l.unlock();
		return true;
	}
}