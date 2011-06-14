#include <iostream>
#include <stdlib.h>

/* written by martin scharm
 * see  https://binfalse.de
 *
 * you have to take a various number of o's
 * from *one* of the stacks. if you did so,
 * the artificial intelligence will do the
 * same. winner is the one who clears the
 * last stack! so think about before doing ;)
 */

void err (std::string s)
{
	std::cout << s << std::endl;
	std::cout << "USAGE:" << std::endl << "\t-n\tnumber of stacks [2..30]" << std::endl << "\t-m\tmaximal stack size [5..50]" << std::endl;
	exit (1);
}

void help ()
{
	std::cout << "written by martin scharm" << std::endl;
	std::cout << "see  https://binfalse.de" << std::endl << std::endl;
	std::cout << "you have to take a various number of o's" << std::endl;
	std::cout << "from *one* of the stacks. if you did so," << std::endl;
	std::cout << "the artificial intelligence will do the" << std::endl;
	std::cout << "same. winner is the one who clears the" << std::endl;
	std::cout << "last stack! so think about before doing ;)" << std::endl;
	err ("");
}

void draw (int *stacks, int num)
{
	std::cout << std::endl << "----------------------------------------" << std::endl << "stack\tsize" << std::endl;
	for (int i = 0; i < num; i++)
	{
		std::cout << i << ":\t";
		for (int j = 0; j < stacks[i]; j++)
			std::cout << 'o';
		std::cout << " (" << stacks[i] << ")" << std::endl;
	}
	std::cout << "----------------------------------------" << std::endl;
}

void inform (bool player)
{
	if (player)
		std::cout << "wow, gratz! lucky punch or a systematic win?" << std::endl;
	else
		std::cout << "haha, no chance against cpu's?" << std::endl;
}

bool playersTurn (int *stacks, int num)
{
	int a = 0, s = -1;
	while (s < 0 || s >= num || stacks[s] < 1)
	{
		draw (stacks, num);
		std::cout << "which stack? (0.." << num - 1 << ") ";
		std::cin >> s;
	}
	while (a < 1 || a > stacks[s])
	{
		draw (stacks, num);
		std::cout << "how much from stack " << s << "? (1.." << stacks[s] << ") ";
		std::cin >> a;
	}
	stacks[s] -= a;
	if (stacks[s] == 0)
	{
		for (int i = 0; i < num; i++)
			if (stacks[i] != 0) return false;
		return true;
	}
	return false;
}

bool artisTurn (int *stacks, int num)
{
	int sum = stacks[0], a = 0, s = -1;
	for (int i = 1; i < num; i++)
		sum = sum xor stacks[i];
	if (sum != 0)
		for (int i = 0; i < num; i++)
		{
			int tmp = sum xor stacks[i];
			if (tmp < stacks[i])
			{
				s = i;
				a = stacks[i] - tmp;
			}
		}
	while (s < 0 || s >= num || stacks[s] < 1) s = rand () % num;
	while (a < 1 || a > stacks[s]) a = 1 + (rand () % stacks[s]);
	stacks[s] -= a;
	std::cout << std::endl << ">>>>>>   the artificial intelligence took " << a << " o's from stack " << s << std::endl;
	
	if (stacks[s] == 0)
	{
		for (int i = 0; i < num; i++)
			if (stacks[i] != 0) return false;
		return true;
	}
	return false;
}

int main (int argc, char **argv)
{
	int numStacks = 5, maxStackSize = 10, *stacks;
	bool player = true, fin = false;
	for (int i = 1; i < argc; i++)
	{
		std::string a = argv[i];
		if (i + 1 < argc)
		{
			if (a == "-n")
			{
				numStacks = atoi (argv[i+1]);
				i++;
				continue;
			}
			if (a == "-m")
			{
				maxStackSize = atoi (argv[i+1]);
				i++;
				continue;
			}
		}
		if (a == "-h" || a == "--help")
		{
			help ();
		}
	}
	if (numStacks < 2 || numStacks > 30) err ("number of stacks should be in [2..30]");
	if (maxStackSize < 5 || maxStackSize > 50) err ("maximum stack size should be in [5..50]");
	srand (time (0));
	
	stacks = new int [numStacks];
	for (int i = 0; i < numStacks; i++)
		stacks[i] = 1 + (rand () % maxStackSize);
	
	while (!fin)
	{
		if (player) fin = playersTurn (stacks, numStacks);
		else fin = artisTurn (stacks, numStacks);
		if (fin) inform (player);
		player = !player;
	}
	std::cout << "done.." << std::endl;
	return 0;
}
